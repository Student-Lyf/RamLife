import "package:firestore/data.dart";
import "package:firestore/faculty.dart";
import "package:firestore/helpers.dart";
import "package:firestore/students.dart";

class ZoomLogic {
	static Map<String, List<Period>> getPeriods(
		Map<Letter, List<List<List<String>>>> schedule
	) {
		final Map<String, List<Period>> result = DefaultMap((_) => []);
		for (
			final MapEntry<Letter, List<List<List<String>>>> scheduleEntry in 
			schedule.entries
		) {
			for (
				final MapEntry<int, List<List<String>>> periodEntry in 
				scheduleEntry.value.asMap().entries
			) {
				for (final List<String> grade in periodEntry.value) {
					for (final String sectionId in grade) {
						result [sectionId].add(
							Period(
								day: scheduleEntry.key,
								id: sectionId,
								period: periodEntry.key + 1,
								room: "Zoom",
							)
						);
					}
				}
			}
		}
		return result;
	}

	static void verifySection({
		@required Map<String, List<Period>> periods,
		@required Map<String, String> sectionTeachers,	
	}) {
		for (final MapEntry<String, List<Period>> periodEntry in periods.entries) {
			final String sectionId = periodEntry.key;
			assert(sectionId.contains("-"), "Invalid section ID: $sectionId.");
			assert(
				sectionTeachers.containsKey(sectionId), 
				"Unrecognized section: $sectionId."
			);

			for (final Period period in periodEntry.value) {
				assert (
					period != null && period.id != null,
					"Invalid period for $sectionId: $period"
				);
			}
		}
	}

	static Future<List<User>> getStudents(
		Map<String, List<Period>> periods
	) async {
		final Map<String, User> students = await Logger.logValue(
			"students", StudentReader.getStudents
		);
		final Map<String, List<String>> studentSections = await Logger.logValue(
			"student sections", StudentReader.getStudentClasses
		);
		final Map<User, Map<Letter, List<Period>>> schedules = await Logger.logValue(
			"student schedules", () => StudentLogic.getSchedules(
				periods: periods,
				studentClasses: studentSections,
				students: students,
			)
		);

		final Map<User, String> homerooms = StudentLogic.homerooms; 
		Logger.debug("Homerooms", homerooms);

		Logger.verbose("Ignoring ${StudentLogic.seniors.length} seniors");

		return Logger.logValue(
			"students with schedules", () => StudentLogic.getStudentsWithSchedules(
				schedules: schedules,
				homerooms: homerooms,
				homeroomLocations: DefaultMap((_) => "Unavailable"),
			)
		);
	}

	static Future<List<User>> getFaculty({
		@required Map<String, List<Period>> periods,
		@required Map<String, String> sectionTeachers,
	}) async {
		final Map<String, User> faculty = await Logger.logValue(
			"faculty", FacultyReader.getFaculty,
		);
		final Map<User, Set<String>> facultySections = await Logger.logValue(
			"faculty sections", () => FacultyLogic.getFacultySections(
				faculty: faculty,
				sectionTeachers: sectionTeachers,
			)
		);
		return Logger.logValue(
			"faculty with schedule", () => FacultyLogic.getFacultyWithSchedule(
				facultySections: facultySections,
				sectionPeriods: periods,
			)
		);
	}
}
