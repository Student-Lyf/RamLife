import "package:meta/meta.dart";

import "schedule.dart";
import "time.dart";

/// A day at Ramaz. 
/// 
/// Each day has a [name] and [schedule] property.
/// The [name] property decides which schedule to show,
/// while the [schedule] property decides what time slots to give the periods. 
@immutable
class Day {
	/// Gets the calendar for the whole year.
	/// 
	/// Each element of [year]'s months should be a JSON representation of a [Day].
	/// See [Day.fromJson] for how to represent a Day in JSON. 
	static List<List<Day?>> getCalendar(List<List<Map?>> year) => [
		for (final List<Map?> month in year) [
			for (final Map? day in month)
				if (day == null) null
				else Day.fromJson(day)
		]
	];

	/// Gets the Day for [date] in the [calendar].
	static Day? getDate(List<List<Day?>> calendar, DateTime date) => 
		calendar [date.month - 1] [date.day - 1];

	/// The name of this day. 
	/// 
	/// This decides which schedule of the student is shown. 
	final String name;

	/// The time allotment for this day.
	/// 
	/// See the [Schedule] class for more details.
	final Schedule schedule;

	/// Returns a new Day from a [name] and [Schedule].
	const Day({
		required this.name,
		required this.schedule
	});

	/// Returns a Day from a JSON object.
	/// 
	/// `json ["name"]` and `json ["schedule"]` must not be null.
	/// `json ["schedule"]` must be the name of a schedule in the calendar. 
	factory Day.fromJson(Map json) {
		final String scheduleName = json ["schedule"];
		final Schedule? schedule = Schedule.schedules.firstWhere(
			(Schedule schedule) => schedule.name == scheduleName
		);
		if (schedule == null) {
			throw ArgumentError.value(
				json ["schedule"],  // problematic value
				"scheduleName",     // description of this value
				"Unrecognized schedule name"  // error message
			);
		}
		return Day(name: json ["name"], schedule: schedule);
	}

	@override 
	String toString() => displayName;

	@override
	int get hashCode => name.hashCode;

	@override 
	bool operator == (dynamic other) => other is Day && 
		other.name == name &&
		other.schedule == schedule;

	/// Returns a JSON representation of this Day. 
	Map toJson() => {
		"name": name,
		"schedule": schedule.name,
	};

	/// A human-readable string representation of this day.
	String get displayName => "$name ${schedule.name}";

	/// Whether to say "a" or "an".
	/// 
	/// Remember, [name] can be a letter and not a word. 
	/// So a letter like "R" might need "an" while "B" would need "a".
	String get n => 
		{"A", "E", "I", "O", "U"}.contains(name [0])
		|| {"A", "M", "R", "E", "F"}.contains(name) ? "n" : "";

	/// The period right now. 
	/// 
	/// Uses [schedule] to calculate the time slots for all the different periods,
	/// and uses [DateTime.now()] to look up what period it is right now. Also 
	/// makes use of [Range] and [Time] comparison operators.
	int? getCurrentPeriod() {
		final Time time = Time.fromDateTime(DateTime.now());
		for (int index = 0; index < schedule.periods.length; index++) {
			final Range range = schedule.periods [index].time;
			if (range.contains(time)  // during class
				|| (  // between periods
					index != 0 && 
					schedule.periods [index - 1].time < time && 
					range > time
				)
			) {
				return index;
			}
			return null;
		}
	}
}
