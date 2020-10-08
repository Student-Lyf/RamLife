import "package:firestore/data.dart";
import "package:firestore/helpers.dart" show DefaultMap, Logger;
import "package:firestore/constants.dart";

// for doc comments
import "package:firestore/sections.dart"; 
import "package:firestore/students.dart"; 
import "reader.dart";  

/// A collection of functions to index faculty data. 
/// 
/// No function in this class reads data from the data files, just works logic
/// on them. This helps keep the program modular, by separating the data sources
/// from the data indexing.
class FacultyLogic {
	/// Maps faculty to the sections they teach.
	/// 
	/// This function works by taking several arguments: 
	/// 
	/// - faculty, from [FacultyReader.getFaculty] 
	/// - sectionTeachers, from [SectionReader.getSectionTeachers] with `id: true`
	/// 
	/// These are kept as parameters instead of calling the functions by itself
	/// in order to keep the data and logic layers separate. 
	static Map<User, Set<String>> getFacultySections({
		@required Map<String, User> faculty,
		@required Map<String, String> sectionTeachers,
	}) {
		final Map<User, Set<String>> result = DefaultMap((_) => {});
		final Set<String> missingEmails = {};

		for (final MapEntry<String, String> entry in sectionTeachers.entries) {
			final String sectionId = entry.key;
			final String facultyId = entry.value;

			// Teaches a class, but doesn't have basic faculty data.
			if (!faculty.containsKey(facultyId)) {
				missingEmails.add(facultyId);
				continue;
			}

			result [faculty [facultyId]].add(sectionId);
		}

		if (missingEmails.isNotEmpty) {
			Logger.warning("Missing emails for $missingEmails");
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
	/// - facultySections, from [getFacultySections] 
	/// - sectionPeriods, from [StudentReader.getPeriods]
	/// 
	/// These are kept as parameters instead of calling the functions by itself
	/// in order to keep the data and logic layers separate. 
	static List<User> getFacultyWithSchedule({
		@required Map<User, Set<String>> facultySections,
		@required Map<String, List<Period>> sectionPeriods,
	}) {
		// The schedule for each teacher.
		final Map<User, List<Period>> schedules = {};

		// Faculty with homerooms to set.
		// 
		// This cannot happen while looping over them, since it would modify the 
		// iterable being looped over, causing several errors. Instead, they are 
		// saved to this map and processed later.
		final Map<User, User> replaceHomerooms = {};

		// Section IDs which are taught but never meet.
		final Set<String> missingPeriods = {};

		// Faculty missing a homeroom.
		// 
		// This will be logged at the debug level.
		final Set<User> missingHomerooms = {};

		// Loop over teacher sections and get their periods.
		for (final MapEntry<User, Set<String>> entry in facultySections.entries) {
			final List<Period> periods = [];
			for (final String sectionId in entry.value) {
				if (sectionPeriods.containsKey(sectionId)) {
					sectionPeriods[sectionId].forEach(periods.add);
				} else if (sectionId.startsWith("UADV")) {
					// will be overwritten in another loop
					replaceHomerooms [entry.key] = entry.key.addHomeroom(
						homeroom: sectionId,
						homeroomLocation: "Unavailable",
					);
				} else {
					missingPeriods.add(sectionId);
				}
			}
			schedules [entry.key] = periods;
		}

		// Create and save faculty homerooms
		// 
		// This cannot happen in the loop above since it would change the iterable 
		// while looping over it, causing several errors. Instead, the old [User] 
		// object and the new one are saved to `replaceHomerooms`.
		for (final User faculty in schedules.keys.toList()) {
			if (!replaceHomerooms.containsKey(faculty)) {
				missingHomerooms.add(faculty);
			}

			final List<Period> schedule = schedules.remove(faculty);
			assert(
				schedule != null,
				"Error adding homeroom to $faculty"
			);
			final User newFaculty = replaceHomerooms.containsKey(faculty) 
				? replaceHomerooms[faculty]
				: faculty.addHomeroom(  // will be overriden
					homeroom: "TEST_HOMEROOM",
					homeroomLocation: "Unavailable",
				);
			schedules [newFaculty] = schedule;
		}

		// Some logging
		if (missingPeriods.isNotEmpty) {
			Logger.debug("Missing periods", missingPeriods);
		}
		if (missingHomerooms.isNotEmpty) {
			Logger.debug("Missing homerooms", missingHomerooms);
		}

		// Compiles a list of periods into a full schedule.
		final List<User> result = [];
		for (final MapEntry<User, List<Period>> entry in schedules.entries) {
			final DefaultMap<String, List<Period>> schedule = DefaultMap(
				(String letter) => List.filled(Period.periodsInDay [letter], null)
			);

			for (final Period period in entry.value) {
				schedule [period.day] [period.period - 1] = period;
			}
			schedule.setDefaultForAll(dayNames);
			result.add(entry.key.addSchedule(schedule));
		}

		return result;
	}
}
