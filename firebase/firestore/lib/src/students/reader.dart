import "package:firestore/data.dart";
import "package:firestore/helpers.dart";

class StudentReader {
	static Future<Map<String, Student>> getStudents() async => {
		await for (final Map<String, String> entry in csvReader(DataFiles.students)) 
			entry ["ID"]: Student(
				first: entry ["First Name"],
				last: entry ["Last Name"],
				email: entry ["Student E-mail"],
				id: entry ["ID"],
			)
	};

	static Map<String, String> homeroomLocations = {};  // filled by getPerios

	static Future<Map<String, List<Period>>> getPeriods() async {
		final Map<String, List<Period>> result = DefaultMap((_) => []);
			await for (
				final Map<String, String> entry in 
				csvReader(DataFiles.sectionSchedule)
			) {
				final String sectionID = entry ["SECTION_ID"];
				final String day = entry ["WEEKDAY_NAME"];
				final Letter letter = stringToLetter [day];
				final String periodString = entry ["BLOCK_NAME"];
				final String room = entry ["ROOM"];
				final int periodNumber = int.tryParse(periodString);
				if (periodNumber == null) {
					if (periodString == "HOMEROOM") {
						homeroomLocations [sectionID] = room;
					}
					continue;
				} 
				final Period period = Period(
					day: letter,
					room: room,
					id: sectionID,
					period: periodNumber,
				);
				result [sectionID].add(period);
			}
		return result;
	}

	static Future<Map<String, List<String>>> getStudentClasses() async {
		final Map<String, List<String>> result = DefaultMap((_) => []);
		await for (final Map<String, String> entry in csvReader(DataFiles.schedule)) {
			result [entry ["STUDENT_ID"]].add(entry ["SECTION_ID"]);
		}
		return result;
	}

	static Future<Map<String, Semesters>> getSemesters() async => {
		await for (final Map<String, String> entry in csvReader(DataFiles.section))
			entry ["SECTION_ID"]: Semesters(
				semester1: entry ["TERM1"] == "Y",
				semester2: entry ["TERM2"] == "Y",
				sectionID: entry ["SECTION_ID"]  // for debugging
			)
	};
}