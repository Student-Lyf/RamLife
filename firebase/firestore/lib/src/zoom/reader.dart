import "package:firestore/data.dart";
import "package:firestore/helpers.dart";

class ZoomReader {
	static const Map<Letter, int> periodsInLetter = {
		Letter.M: 5,
		Letter.R: 4,
		Letter.A: 4,
		Letter.B: 4,
		Letter.C: 4,
		Letter.E: 3,
		Letter.F: 3,		
	};

	static const List<Letter> zoomLetters = [
		Letter.M, Letter.A, Letter.B, Letter.R, Letter.F
	];

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
