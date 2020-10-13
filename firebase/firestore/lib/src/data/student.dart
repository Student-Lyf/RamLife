import "package:meta/meta.dart";

import "package:firestore/constants.dart";
import "package:firestore/helpers.dart";

import "schedule.dart";

/// A user object.
/// 
/// At first, users need to be tracked by their IDs and personal data. After 
/// their schedules are compiled, those need to be added to the object. However,
/// since this class is [immutable], call [addSchedule] to receive a new 
/// [User] object with the added schedule data.
@immutable
class User extends Serializable {
	/// Warns for any users with no classes in their schedule.
	static void verifySchedules(Iterable<User> users) {
		final Set<User> missingSchedules = users.where(
			(User user) => user.hasNoClasses
		).toSet();

		if (missingSchedules.isNotEmpty) {
			// Warning since it can be a sign of data corruption.
			Logger.warning("Missing schedules for $missingSchedules");
		}
	}

	/// Converts a list of [Period] objects to JSON. 
	static List<Map<String, dynamic>> scheduleToJson(List<Period> schedule) => [
		for (final Period period in schedule) 
			period?.json
	];

	static final dayNamesList = List<String>.from(dayNames);

	/// This user's email.
	final String email;

	/// This user's first name.
	final String first;

	/// This user's last name.
	final String last;

	/// This user's ID.
	final String id;

	/// The section ID of this user's homeroom.
	final String homeroom;

	/// The location of this user's homeroom.
	final String homeroomLocation;

	/// This user's schedule.
	/// 
	/// This must have all the letters inside. 
	final Map<String, List<Period>> schedule;

	/// This user's full name.
	String get name => "$first $last";

	/// Creates a user object.
	User({
		@required this.first,
		@required this.last,
		@required this.email,
		@required this.id,
		this.homeroom,
		this.homeroomLocation,
		this.schedule,
	}) : 
		assert(id != null, "Could not find ID for user"),
		assert(
			first != null && last != null && email != null,
			"Could not find name for user: $id"
		)
	{
		if (schedule == null) {
			return;
		}
		assert(
			homeroom != null,
			"Could not find homeroom for user: ${toString()}"
		);
		assert(
			homeroomLocation != null,
			"Could not find homeroom location for user: ${toString()}"
		);
		for (final String dayName in dayNames) {
			assert(
				schedule.containsKey(dayName), 
				"$name does not have a schedule for $dayName days,"
			);
		}
	}

	/// If this user has no classes.
	bool get hasNoClasses => schedule.values.every(
		(List<Period> daySchedule) => daySchedule.every(
			(Period period) => period == null
		)
	);

	/// Returns a new [User] with added data. 
	/// 
	/// This fills in [homeroom] and [homeroomLocation], and is needed since 
	/// [User] objects are [immutable].
	User addHomeroom({
		@required String homeroom, 
		@required String homeroomLocation,
	}) => User(
		first: first,
		last: last,
		email: email,
		id: id,
		homeroom: homeroom,
		homeroomLocation: homeroomLocation,
	);

	/// Returns a new [User] with added data. 
	/// 
	/// This fills in [schedule], and is needed since [User] objects 
	/// are [immutable].
	/// 
	/// To fill in the homeroom as well, call this function on the return value
	/// of [addHomeroom].
	User addSchedule(Map<String, List<Period>> schedule) => User(
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
		for (final String dayName in dayNames) 
			dayName: scheduleToJson(schedule [dayName]),
		"homeroom": homeroom,
		"homeroom meeting room": homeroomLocation,
		"email": email,
		"dayNames": dayNamesList, 
	};

	@override
	String toString() => "$name ($id)";
}
