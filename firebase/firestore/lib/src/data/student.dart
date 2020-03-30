import "package:meta/meta.dart";

import "package:firestore/helpers.dart";
import "package:firestore/data.dart";

/// A student object.
/// 
/// At first, students need to be tracked by their IDs and personal data. After 
/// their schedules are compiled, those need to be added to the object. However,
/// since this class is [immutable], call [addSchedule] to receive a new 
/// [Student] object with the added schedule data.
@immutable
class Student extends Serializable {
	/// Warns for any students with no classes in their schedule.
	static void verifySchedules(Iterable<Student> students) {
		final Set<Student> missingSchedules = students.where(
			(Student student) => student.hasNoClasses
		).toSet();

		if (missingSchedules.isNotEmpty) {
			// Warning since it can be a sign of data corruption.
			Logger.warning("Missing schedules for $missingSchedules");
		}
	}

	/// Converts a list of [Period] objects to JSON. 
	static List<Map<String, dynamic>> scheduleToJson(List<Period> schedule) => [
		for (final Period period in schedule) 
			period.json
	];

	/// This student's email.
	final String email;

	/// This student's first name.
	final String first;

	/// This student's last name.
	final String last;

	/// This student's ID.
	final String id;

	/// The section ID of this student's homeroom.
	final String homeroom;

	/// The location of this student's homeroom.
	final String homeroomLocation;

	/// This student's schedule.
	/// 
	/// This must have all the letters inside. 
	final Map<Letter, List<Period>> schedule;

	/// This student's full name.
	String get name => "$first $last";

	/// Creates a student object.
	Student({
		@required this.first,
		@required this.last,
		@required this.email,
		@required this.id,
		this.homeroom,
		this.homeroomLocation,
		this.schedule,
	}) : 
		assert(id != null, "Could not find ID for student"),
		assert(
			first != null && last != null && email != null,
			"Could not find name for student: $id"
		)
	{
		if (schedule == null) {
			return;
		}
		assert(
			homeroom != null,
			"Could not find homeroom for student: ${toString()}"
		);
		assert(
			homeroomLocation != null,
			"Could not find homeroom location for student: ${toString()}"
		);
		for (final Letter letter in Letter.values) {
			assert(
				schedule.containsKey(letter), 
				"$name does not have a schedule for $letter days,"
			);
		}
	}

	/// If this user has no classes.
	bool get hasNoClasses => schedule.values.every(
		(List<Period> daySchedule) => daySchedule.every(
			(Period period) => period == null
		)
	);

	/// Returns a new [Student] with added data. 
	/// 
	/// This fills in [homeroom] and [homeroomLocation], and is needed since 
	/// [Student] objects are [immutable].
	Student addHomeroom({
		@required String homeroom, 
		@required String homeroomLocation,
	}) => Student(
		first: first,
		last: last,
		email: email,
		id: id,
		homeroom: homeroom,
		homeroomLocation: homeroomLocation,
	);

	/// Returns a new [Student] with added data. 
	/// 
	/// This fills in [schedule], and is needed since [Student] objects 
	/// are [immutable].
	/// 
	/// To fill in the homeroom as well, call this function on the return value
	/// of [addHomeroom].
	Student addSchedule(Map<Letter, List<Period>> schedule) => Student(
		first: first, 
		last: last,
		email: email,
		id: id,
		homeroom: homeroom,
		homeroomLocation: homeroomLocation,
		schedule: schedule,
	);

	@override
	Map<String, dynamic> get json => {
		"M": scheduleToJson(schedule [Letter.M]),
		"R": scheduleToJson(schedule [Letter.R]),
		"A": scheduleToJson(schedule [Letter.A]),
		"B": scheduleToJson(schedule [Letter.B]),
		"C": scheduleToJson(schedule [Letter.C]),
		"E": scheduleToJson(schedule [Letter.E]),
		"F": scheduleToJson(schedule [Letter.F]),
		"homeroom": homeroom,
		"homeroom meeting room": homeroomLocation,
	};

	@override
	String toString() => "$name ($id)";
}
