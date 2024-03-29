import "types.dart";
import "package:meta/meta.dart";

import "reminders/reminder_time.dart";

export "reminders/period_reminder_time.dart";
export "reminders/reminder_time.dart";
export "reminders/subject_reminder_time.dart";

/// A user-generated reminder.
@immutable
class Reminder {
	/// Returns all reminders from a list of reminders that should be shown. 
	/// 
	/// All possible parameters are required. 
	/// This function delegates logic to [ReminderTime.doesApply]
	static List<int> getReminders({
		required List<Reminder> reminders,
		required String? dayName,
		required String? period,
		required String? subject,
	}) => [
		for (int index = 0; index < reminders.length; index++)
			if (reminders [index].time.doesApply(
				dayName: dayName,
				period: period,
				subject: subject,				
			)) index,
	];

	/// Returns a list of reminders from a list of JSON objects. 
	/// 
	/// Calls [Reminder.fromJson] for every JSON object in the list.
	static List<Reminder> fromList(List<dynamic> reminders) => [
		for (final dynamic json in reminders)
			Reminder.fromJson(Json.from(json)),
	];

	/// The message this reminder should show. 
	final String message;

	/// The [ReminderTime] for this reminder. 
	final ReminderTime time;

	/// A unique ID for this reminder.
	/// 
	/// Used to locate this in a database.
	final String id;

	/// Creates a new reminder.
	const Reminder({
		required this.message,
		required this.time,
		required this.id,
	});

	/// Creates a new [Reminder] from a JSON object.
	/// 
	/// Uses `json ["message"]` for the message and passes `json["time"]` 
	/// to [ReminderTime.fromJson]
	Reminder.fromJson(dynamic json) :
		message = json ["message"],
		id = json ["id"],
		time = ReminderTime.fromJson(Json.from(json ["time"]));

	@override String toString() => "$message ($time)";

	/// Returns a JSON representation of this reminder.
	Json toJson() => {
		"message": message,
		"time": time.toJson(),
		"id": id,
	};
}
