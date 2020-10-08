import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/constants.dart";

import "reader.dart";  // for doc comments, can be removed if necessary.

/// A collection of functions to index student data. 
/// 
/// No function in this class reads data from the data files, just works logic
/// on them. This helps keep the program modular, by separating the data sources
/// from the data indexing.
/// 
/// NOTE: [homerooms] and [seniors] are filled by [getSchedules]. Until that 
/// function is called, their values will be null and [Map.[]] and 
/// [Set.contains] cannot be used on them.
class StudentLogic {
	/// A list of expelled students. 
	static const Set<String> expelled = {};

	/// Maps students to their homeroom section IDs.
	/// 
	/// This map is populated by [getSchedules].
	static Map<User, String> homerooms;

	/// A collection of all seniors. 
	/// 
	/// Seniors do not have regular homerooms, so if they are present in this set, 
	/// their homerooms will be ignored. 
	/// 
	/// This set is populated by [getSchedules].
	static Set<User> seniors;

	/// Builds a student's schedule.
	/// 
	/// This function works by taking several arguments: 
	/// 
	/// - students, from [StudentReader.getStudents]
	/// - periods, from [StudentReader.getPeriods]
	/// - studentClasses, from [StudentReader.getStudentClasses]
	/// - semesters, from [StudentReader.getSemesters]
	/// 
	/// These are kept as parameters instead of calling the functions by itself
	/// in order to keep the data and logic layers separate. 
	/// 
	/// Additionally, this function populates [seniors] and [homerooms].
	static Map<User, Map<String, List<Period>>> getSchedules({
		@required Map<String, User> students,
		@required Map<String, List<Period>> periods,
		@required Map<String, List<String>> studentClasses, 
		Map<String, Semesters> semesters,
	}) {
		homerooms = {};
		seniors = {};
		final Map<User, DefaultMap<String, List<Period>>> result = DefaultMap(
			(_) => DefaultMap((String letter) => 
				List.filled(Period.periodsInDay[letter], null))
		);
		for (final MapEntry<String, List<String>> entry in studentClasses.entries) {
			final User student = students [entry.key];
			for (final String sectionId in entry.value) {
				if (sectionId.contains("UADV")) {
					homerooms [student] = sectionId;
					continue;
				}

				if (semesters != null && !semesters [sectionId].semester2) {
					continue;
				} else if (sectionId.startsWith("12")) {
					seniors.add(student);
				}

				assert(
					periods [sectionId] != null, 
					"Could not find $sectionId in the schedule."
				);

				for (final Period period in periods [sectionId]) {
					result [student] [period.day] [period.period - 1] = period;
				}
			}
		}
		for (final schedule in result.values) {
			schedule.setDefaultForAll(dayNames);
		}
		return result;
	}

	/// Returns complete [User] objects.
	/// 
	/// This function returns [User] objects with more properties than before.
	/// See [User.addSchedule] for which properties are added. 
	/// 
	/// This function works by taking several arguments: 
	/// 
	/// - schedules, from [getSchedules] 
	/// - homerooms, from [homerooms]
	/// - homeroomLocations, from [StudentReader.homeroomLocations]
	/// 
	/// These are kept as parameters instead of calling the functions by itself
	/// in order to keep the data and logic layers separate. 
	static List<User> getStudentsWithSchedules({
		@required Map<User, Map<String, List<Period>>> schedules, 
		@required Map<User, String> homerooms,
		@required Map<String, String> homeroomLocations,
	}) => [
		for (
			final MapEntry<User, Map<String, List<Period>>> entry in 
			schedules.entries
		)
			if (!expelled.contains(entry.key.id))
				entry.key.addHomeroom(
					homeroom: seniors.contains(entry.key) 
						? "SENIOR_HOMEROOM"
						: homerooms [entry.key],
					homeroomLocation: homeroomLocations [homerooms [entry.key]],
				).addSchedule(entry.value)
	];
}
