import "package:firestore/data.dart";
import "package:firestore/helpers.dart";

class StudentLogic {
	static const Set<String> expelled = {};

	static Map<Letter, int> periodsInDay = {
		Letter.A: 11, 
		Letter.B: 11,
		Letter.C: 11,
		Letter.M: 11,
		Letter.R: 11, 
		Letter.E: 7,
		Letter.F: 7,
	};

	static final Map<Student, String> homerooms = {};
	static final Set<Student> seniors = {};

	static Map<Student, Map<Letter, List<Period>>> getSchedule({
		@required Map<String, Student> students,
		@required Map<String, List<Period>> periods,
		@required Map<String, List<String>> studentClasses, 
		@required Map<String, Semesters> semesters,
	}) {
		final Map<Student, Map<Letter, List<Period>>> result = DefaultMap(
			(_) => DefaultMap((Letter letter) => 
				List.filled(periodsInDay[letter], null))
		);
		for (final MapEntry<String, List<String>> entry in studentClasses.entries) {
			final Student student = students [entry.key];
			for (final String sectionID in entry.value) {
				if (sectionID.contains("UADV")) {
					homerooms [student] = sectionID;
					continue;
				}

				if (!semesters [sectionID].semester2) {
					continue;
				} else if (sectionID.startsWith("12")) {
					seniors.add(student);
				}

				assert(
					periods [sectionID] != null, 
					"Could not find $sectionID in the schedule."
				);

				for (final Period period in periods [sectionID]) {
					result [student] [period.day] [period.period - 1] = period;
				}
			}
		}
		return result;
	}

	static List<Student> getStudentsWithSchedules({
		@required Map<Student, Map<Letter, List<Period>>> schedules, 
		@required Map<Student, String> homerooms,
		@required Map<String, String> homeroomLocations,
	}) => [
		for (
			final MapEntry<Student, Map<Letter, List<Period>>> entry in 
			schedules.entries
		)
			if (!expelled.contains(entry.key.id))
				entry.key.addSchedule(
					schedule: entry.value, 
					homeroom: seniors.contains(entry.key) 
						? "SENIOR_HOMEROOM"
						: homerooms [entry.key],
					homeroomLocation: homeroomLocations [homerooms [entry.key]],
				)
	];
}
