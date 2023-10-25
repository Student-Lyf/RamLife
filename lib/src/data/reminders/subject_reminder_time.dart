import "../types.dart";
import "reminder_time.dart";

/// A [ReminderTime] that depends on a subject. 
class SubjectReminderTime extends ReminderTime {
	/// The name of the subject this [ReminderTime] depends on.
	final String name;

	/// Returns a new [SubjectReminderTime]. All parameters must be non-null.
	const SubjectReminderTime({
		required this.name,
		required super.repeats,
	}) : super (type: ReminderTimeType.subject);

	/// Returns a new [SubjectReminderTime] from a JSON object.
	/// 
	/// The fields `repeats` and `name` must not be null.
	SubjectReminderTime.fromJson(Json json) :
		name = json ["name"],
		super (repeats: json ["repeats"], type: ReminderTimeType.subject);

	@override
	String toString() => (repeats ? "Repeats every " : "") + name;

	@override 
	Json toJson() => {
		"name": name,
		"repeats": repeats,
		"type": reminderTimeToString [type],
	};

	/// Returns true if this instance's [subject] field 
	/// matches the `subject` parameter.
	@override
	bool doesApply({
		required String? dayName, 
		required String? subject, 
		required String? period,
	}) => subject == name;
}
