import "dart:convert";

import "package:meta/meta.dart";

import "special.dart";
import "time.dart";

/// A day at Ramaz. 
/// 
/// Each day has a [name] and [special] property.
/// The [name] property decides which schedule to show,
/// while the [special] property decides what time slots to give the periods. 
@immutable
class Day {
	/// Gets the calendar for the whole year.
	/// 
	/// Each element of [data]'s months should be a JSON representation of a [Day].
	/// See [Day.fromJson] for how to represent a Day in JSON. 
	static List<List<Day?>> getCalendar(
		List<List<Map<String, dynamic>?>> data
	) => [
		for (final List<Map<String, dynamic>?> month in data)
			getMonth(month)
	];

	/// Parses a particular month from JSON. 
	/// 
	/// See [Day.getCalendar] for details.
	static List<Day?> getMonth(List<Map<String, dynamic>?> data) => [
		for (final Map<String, dynamic>? json in data)
			if (json == null) null
			else Day.fromJson(json)
	];

	/// Converts a month in the calendar to JSON. 
	/// 
	/// This is how it is currently stored in the database. 
	static List<Map<String, dynamic>?> monthToJson(List<Day?> month) => [
		for (final Day? day in month)
			day?.toJson()
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
	/// See the [Special] class for more details.
	final Special special;

	/// Returns a new Day from a [name] and [Special].
	const Day({
		required this.name,
		required this.special
	});

	/// Returns a Day from a JSON object.
	/// 
	/// `json ["name"]` and `json ["special"]` must not be null.
	/// 
	/// `json ["special"]` may be: 
	/// 
	/// 1. One of the specials from [Special.specials].
	/// 2. JSON of a special. See [Special.fromJson].
	/// 
	/// This factory is not a constructor so it can dynamically check 
	/// for a valid [name] while keeping the field final.
	factory Day.fromJson(Map<String, dynamic> json) {
		if (!json.containsKey("name")) {
			throw JsonUnsupportedObjectError(json);
		}
		final String name = json ["name"];
		final jsonSpecial = json ["special"];
		final Special special = Special.fromJson(jsonSpecial);
		return Day(name: name, special: special);
	}

	@override 
	String toString() => displayName;

	@override
	int get hashCode => name.hashCode;

	@override 
	bool operator == (dynamic other) => other is Day && 
		other.name == name &&
		other.special == special;

	/// Returns a JSON representation of this Day. 
	/// 
	/// Will convert [special] to its name if it is a built-in special.
	/// Otherwise it will convert it to JSON form. 
	Map<String, dynamic> toJson() => {
		"name": name,
		"special": Special.stringToSpecial.containsKey(special.name)
			? special.name
			: special.toJson()
	};

	/// A human-readable string representation of this day.
	/// 
	/// If [name] is null, returns null. 
	/// Otherwise, returns [name] and [special].
	/// If [special] was left as the default, will only return the [name].
	String get displayName => "$name ${special.name}";

	/// Whether to say "a" or "an".
	/// 
	/// Remember, [name] can be a letter and not a word. 
	/// So a letter like "R" might need "an" while "B" would need "a".
	String get n => 
		{"A", "E", "I", "O", "U"}.contains(name [0])
		|| {"A", "M", "R", "E", "F"}.contains(name) ? "n" : "";

	/// The period right now. 
	/// 
	/// Uses [special] to calculate the time slots for all the different periods,
	/// and uses [DateTime.now()] to look up what period it is right now. 
	/// 
	/// See [Time] and [Range] for implementation details.
	int? get period {
		final Time time = Time.fromDateTime (DateTime.now());
		for (int index = 0; index < (special.periods.length); index++) {
			final Range range = special.periods [index];
			if (
				range.contains(time) ||  // during class
				(  // between periods
					index != 0 && 
					special.periods [index - 1] < time && 
					range > time
				)
			) {
				return index;
			}
		}
		// ignore: avoid_returning_null
		return null;
	}
}
