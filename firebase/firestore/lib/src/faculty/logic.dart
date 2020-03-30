import "package:firestore/data.dart";
import "package:firestore/helpers.dart" show DefaultMap, Logger;

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
	/// - teachers, from [FacultyReader.getFaculty] 
	/// - sectionTeachers, from [SectionReader.getSectionTeachers] with `id: true`
	/// 
	/// These are kept as parameters instead of calling the functions by itself
	/// in order to keep the data and logic layers separate. 
	static Map<Student, Set<String>> getFacultySections({
		@required Map<String, Student> teachers,
		@required Map<String, String> sectionTeachers,
	}) {
		final Map<Student, Set<String>> result = DefaultMap((_) => {});
		final Set<String> missingEmails = {};

		for (final MapEntry<String, String> entry in sectionTeachers.entries) {
			final String sectionId = entry.key;
			final String facultyId = entry.value;

			// Teaches a class, but doesn't have basic faculty data.
			if (!teachers.containsKey(facultyId)) {
				missingEmails.add(facultyId);
				continue;
			}

			result [teachers [facultyId]].add(sectionId);
		}

		if (missingEmails.isNotEmpty) {
			Logger.warning("Missing emails for $missingEmails");
		}
		return result;
	}

	/// Returns complete [Student] objects.
	/// 
	/// This function returns [Student] objects with more properties than before.
	/// See [Student.addSchedule] for which properties are added. 
	/// 
	/// This function works by taking several arguments: 
	/// 
	/// - teacherSections, from [getFacultySections] 
	/// - sectionPeriods, from [StudentReader.getPeriods]
	/// 
	/// These are kept as parameters instead of calling the functions by itself
	/// in order to keep the data and logic layers separate. 
	static List<Student> getFacultyWithSchedule({
		@required Map<Student, Set<String>> teacherSections,
		@required Map<String, List<Period>> sectionPeriods,
	}) {
		// The schedule for each teacher.
		final Map<Student, List<Period>> schedules = {};

		// Faculty with homerooms to set.
		// 
		// This cannot happen while looping over them, since it would modify the 
		// iterable being looped over, causing several errors. Instead, they are 
		// saved to this map and processed later.
		final Map<Student, Student> replaceHomerooms = {};

		// Section IDs which are taught but never meet.
		final Set<String> missingPeriods = {};

		// Faculty missing a homeroom.
		// 
		// This will be logged at the debug level.
		final Set<Student> missingHomerooms = {};

		// Loop over teacher sections and get their periods.
		for (final MapEntry<Student, Set<String>> entry in teacherSections.entries) {
			final List<Period> periods = [];
			for (final String sectionId in entry.value) {
				if (sectionPeriods.containsKey(sectionId)) {
					sectionPeriods[sectionId].forEach(periods.add);
				} else if (sectionId.startsWith("UADV")) {
					replaceHomerooms [entry.key] = entry.key.addHomeroom(  // will be overriden
						homeroom: sectionId,
						homeroomLocation: "Unavailable",
					);
				} else {
					missingPeriods.add(sectionId);
				}
			}
			schedules [entry.key] = periods;
		}

		// Create and save teacher homerooms
		// 
		// This cannot happen in the loop above since it would change the iterable 
		// while looping over it, causing several errors. Instead, the old [Student] 
		// object and the new one are saved to `replaceHomerooms`.
		for (final Student teacher in schedules.keys.toList()) {
			if (!replaceHomerooms.containsKey(teacher)) {
				missingHomerooms.add(teacher);
			}

			final List<Period> schedule = schedules.remove(teacher);
			assert(
				schedule != null,
				"Error adding homeroom to $teacher"
			);
			final Student newTeacher = replaceHomerooms.containsKey(teacher) 
				? replaceHomerooms[teacher]
				: teacher.addHomeroom(  // will be overriden
					homeroom: "TEST_HOMEROOM",
					homeroomLocation: "Unavailable",
				);
			schedules [newTeacher] = schedule;
		}

		// Some logging
		if (missingPeriods.isNotEmpty) {
			Logger.debug("Missing periods", missingPeriods);
		}
		if (missingHomerooms.isNotEmpty) {
			Logger.debug("Missing homerooms", missingHomerooms);
		}

		// Compiles a list of periods into a full schedule.
		// 
		// TODO: unify this logic with student logic.
		final List<Student> result = [];
		for (final MapEntry<Student, List<Period>> entry in schedules.entries) {
			final DefaultMap<Letter, List<Period>> schedule = DefaultMap(
				(Letter letter) => List.filled(Period.periodsInDay [letter], null)
			);

			for (final Period period in entry.value) {
				schedule [period.day] [period.period - 1] = period;
			}
			schedule.setDefaultForAll(Letter.values);
			result.add(entry.key.addSchedule(schedule));
		}

		// Warn for missing schedules.
		// 
		// TODO: also warn for students.
		final Set<Student> missingSchedules = result.where(
			(Student faculty) => faculty.hasNoClasses
		).toSet();

		if (missingSchedules.isNotEmpty) {
			// Warning since it can be a sign of data corruption.
			Logger.warning("Missing schedules for $missingSchedules");
		}

		return result;
	}
}
