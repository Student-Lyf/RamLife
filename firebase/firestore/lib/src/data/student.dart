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
	}) {
		if (schedule == null) {
			return;
		}
		for (final Letter letter in Letter.values) {
			assert(
				schedule.containsKey(letter), 
				"$name does not have a schedule for $letter days,"
			);
		}
		Period period;
		for (final List<Period> day in schedule.values) {
			for (final Period subject in day) {
				if (subject == null) {
					continue;
				} else {
					period = subject;
					break;
				}
			}
			if (period != null) {
				break;
			}
		}
		if (period == null) {
			Logger.warning("WARNING: Could not find a period for $email.");
		} else {
			assert(period.json.containsKey("id"), "JSON does not have id: $period");
			assert(period.json.containsKey("room"), "JSON does not have room: $period");
			assert(period.json ["id"] is String, "Invalid id: ${period.json ['id']}");
			assert(
				period.json ["room"] is String, 
				"Invalid room: ${period.json ['room']}"
			);
		}
	}

	/// Returns a new [Student] with added data. 
	/// 
	/// This is needed since [Student] objects are immutable.
	Student addSchedule({
		@required Map<Letter, List<Period>> schedule,
		@required String homeroom,
		@required String homeroomLocation,
	}) => Student(
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
		"M": schedule [Letter.M],
		"R": schedule [Letter.R],
		"A": schedule [Letter.A],
		"B": schedule [Letter.B],
		"C": schedule [Letter.C],
		"E": schedule [Letter.E],
		"F": schedule [Letter.F],
		"homeroom": homeroom,
		"homeroom meeting room": homeroomLocation,
	};

	@override
	String toString() => name;
}
