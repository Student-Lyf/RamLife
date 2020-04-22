import "package:firestore/data.dart";
import "package:firestore/helpers.dart";

/// A collection of functions to read Zoom school data.
/// 
/// No function in this class actually performs logic on said data, just returns
/// it. This helps keep the program modular, by separating the data sources from
/// the data indexing.
class ZoomReader {
	/// The periods in a day for Zoom school.
	static const Map<Letter, int> periodsInLetter = {
		Letter.M: 4,
		Letter.R: 4,
		Letter.A: 4,
		Letter.B: 4,
		Letter.C: 0,
		Letter.E: 0,
		Letter.F: 4,
	};

	/// The letters used for Zoom school.
	/// 
	/// Zoom school runs off weekdays instead of letters. However, changing the 
	/// app to work with weekdays would require an app update, which is
	/// non-trivial. To circumvent this, weekdays are mapped to [Letter]s.
	/// M and R are still Monday and Thursday, A and B are Tuesday and Wednesday, 
	/// respectively, and F day is Friday.
	static const List<Letter> zoomLetters = [
		Letter.M, Letter.A, Letter.B, Letter.R, Letter.F
	];

	/// Maps letters to their Zoom schedules.
	/// 
	/// The values of this map are nested lists. The first layer represents a 
	/// period, the second a grade, and the third is all the section IDs that meet
	/// that period for that grade on that day.
	static Future<Map<Letter, List<List<List<String>>>>> getSchedule() async {
		// Sorry, sorry, I know it looks bad
		// Don't worry, it gets better (after this function)
		final Map<Letter, List<List<List<String>>>> result = {
			for (final Letter letter in zoomLetters) letter: [
				for (int period = 0; period < periodsInLetter [letter]; period++) [
					for (int grade = 0; grade < 4; grade++) 
						[]  // all the sections in this period
				]
			]
		};
		int period = -1;
		bool isSecondGradeRow;
		await for(final List<String> line in csvReadLines(DataFiles.zoom)) {
			if (line [1].contains(":")) {  // headers for time and grades
				isSecondGradeRow = line [0].isEmpty;
				if (!isSecondGradeRow) {
					period++;
				}
				continue;
			}

			for (int weekday = 0; weekday < 5; weekday++) {
				for (int grade = 0; grade < 2; grade++) {
					final int index = (weekday * 2) + grade + 1;
					final String cell = line [index];
					if (cell.trim().isEmpty) {
						continue;
					} else if (isSecondGradeRow) {
						grade += 2;
					}

					assert(cell.contains(" "), "Could not parse cell: $cell");
					final String sectionId = (grade + 9).toString().padLeft(2, "0") 
						+ cell.split(" ") [1];

					if (sectionId.startsWith("12")) {
						continue;
					}

					assert(
						sectionId.split("").every(
							(String digit) => int.tryParse(digit) != null || digit == "-"
						),
						"Could not parse section $sectionId"
					);
					result [zoomLetters [weekday]] [period] [grade].add(sectionId);
				}
			}
		}
		return result;
	}
}
