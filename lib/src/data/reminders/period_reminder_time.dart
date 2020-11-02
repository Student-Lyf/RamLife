import "package:meta/meta.dart";

import "reminder_time.dart";

/// A [ReminderTime] that depends on a name and period.
class PeriodReminderTime extends ReminderTime {
	/// The day for when this reminder should be displayed.
	final String dayName;

	/// The period when this reminder should be displayed.
	final String period;

	/// Returns a new [PeriodReminderTime].
	/// 
	/// All parameters must be non-null.
	const PeriodReminderTime({
		@required this.dayName,
		@required this.period,
		@required bool repeats
	}) : super (repeats: repeats, type: ReminderTimeType.period);

	/// Creates a new [ReminderTime] from JSON.
	/// 
	/// `json ["dayName"]` should be one of the valid names.
	/// 
	/// `json ["period"]` should be a valid period for that day,
	/// notwithstanding any schedule changes (like an "early dismissal").
	PeriodReminderTime.fromJson(Map<String, dynamic> json) :
		dayName = json ["dayName"],
		period = json ["period"],
		super (repeats: json ["repeats"], type: ReminderTimeType.period);

	@override
	String toString() => 
		"${repeats ? 'Repeats every ' : ''}$dayName-$period";

	@override 
	Map<String, dynamic> toJson() => {
		"dayName": dayName,
		"period": period,
		"repeats": repeats,
		"type": reminderTimeToString [type],
	};

	/// Returns true if [dayName] and [period] match this instance's fields.
	@override
	bool doesApply({
		@required String dayName, 
		@required String subject, 
		@required String period,
	}) => dayName == this.dayName && period == this.period;

	@override
	String get hash => "$dayName-$period-$repeats";
}
