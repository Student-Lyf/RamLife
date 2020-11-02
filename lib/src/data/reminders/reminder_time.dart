import "dart:convert";

import "package:meta/meta.dart";

import "period_reminder_time.dart";
import "subject_reminder_time.dart";

/// An enum to decide when the reminder should appear. 
/// 
/// `period` means the reminder needs a Day name and a period (as [String])
/// `subject` means the reminder needs a name of a class.
enum ReminderTimeType {
	/// Whether the reminder should be displayed on a specific period.
	period, 

	/// Whether the reminder should be displayed on a specific subject.
	subject
}

/// Used to convert [ReminderTimeType] to JSON.
const Map<ReminderTimeType, String> reminderTimeToString = {
	ReminderTimeType.period: "period",
	ReminderTimeType.subject: "subject",
};

/// Used to convert JSON to [ReminderTimeType].
const Map<String, ReminderTimeType> stringToReminderTime = {
	"period": ReminderTimeType.period,
	"subject": ReminderTimeType.subject,
};

/// A time that a reminder should show.
@immutable
abstract class ReminderTime {
	/// The type of reminder. 
	/// 
	/// This field is here for other objects to use. 
	final ReminderTimeType type;

	/// Whether the reminder should repeat.
	final bool repeats;

	/// Allows its subclasses to be `const`. 
	const ReminderTime({
		@required this.repeats, 
		@required this.type
	});

	/// Initializes a new instance from JSON.
	/// 
	/// Mainly looks at `json ["type"]` to choose which type of 
	/// [ReminderTime] it should instantiate, and then leaves the 
	/// work to that subclass' `.fromJson` method. 
	/// 
	/// Example JSON: 
	/// ```
	/// {
	/// 	"type": "period",
	/// 	"repeats": false,
	/// 	"period": "9",
	/// 	"name": "Monday",
	/// }
	/// ```
	factory ReminderTime.fromJson(Map<String, dynamic> json) {
		switch (stringToReminderTime [json ["type"]]) {
			case ReminderTimeType.period: return PeriodReminderTime.fromJson(json);
			case ReminderTimeType.subject: return SubjectReminderTime.fromJson(json);
			default: throw JsonUnsupportedObjectError(
				json,
				cause: "Invalid time for reminder: $json"
			);
		}
	}

	/// Instantiates new [ReminderTime] with all possible parameters. 
	/// 
	/// Used for cases where the caller doesn't care about the [ReminderTimeType],
	/// such as a UI reminder builder. 
	factory ReminderTime.fromType({
		@required ReminderTimeType type,
		@required String dayName,
		@required String period,
		@required String name,
		@required bool repeats,
	}) {
		switch (type) {
			case ReminderTimeType.period: return PeriodReminderTime(
				period: period,
				dayName: dayName,
				repeats: repeats,
			); case ReminderTimeType.subject: return SubjectReminderTime(
				name: name,
				repeats: repeats,
			); default: throw ArgumentError.notNull("type");
		}
	}

	/// Returns this [ReminderTime] as JSON.
	Map<String, dynamic> toJson();

	/// Checks if the reminder should be displayed.
	/// 
	/// All possible parameters are required. 
	bool doesApply({
		@required String dayName, 
		@required String subject, 
		@required String period,
	});

	/// Returns a String representation of this [ReminderTime].
	///
	/// Used for debugging and throughout the UI.
	@override
	String toString();

	String get hash;
}
