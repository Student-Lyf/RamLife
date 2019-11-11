/// A collection of dataclasses to sufficiently represent time for a student. 
library time_dataclasses;

import "package:flutter/foundation.dart";
import "package:ramaz/constants.dart";

/// The hour and minute representation of a time. 
/// 
/// This is used instead of [Flutter's TimeOfDay](https://api.flutter.dev/flutter/material/TimeOfDay-class.html)
/// to provide the `>` and `<` operators. 
@immutable
class Time {
	/// The hour in 24-hour format. 
	final int hour;

	/// The minutes. 
	final int minutes;

	/// A const constructor.
	const Time (this.hour, this.minutes);

	/// Simplifies a [DateTime] object to a [Time].
	Time.fromDateTime (DateTime date) :
		hour = date.hour, 
		minutes = date.minute;

	/// Returns a new [Time] object from JSON data.
	/// 
	/// The json must have `hour` and `minutes` fields that map to integers.
	Time.fromJson(Map<String, dynamic> json) :
		hour = json ["hour"],
		minutes = json ["minutes"];

	/// Returns this obect in JSON form
	Map<String, dynamic> toJson() => {
		"hour": hour, 
		"minutes": minutes,
	};

	@override 
	int get hashCode => toString().hashCode;

	@override
	bool operator == (dynamic other) => other.runtimeType == Time && 
		other.hour == hour && 
		other.minutes == minutes;

	/// Returns whether this [Time] is before another [Time].
	bool operator < (Time other) => hour < other.hour || 
		(hour == other.hour && minutes < other.minutes);

	/// Returns whether this [Time] is at or before another [Time].
	bool operator <= (Time other) => this < other || this == other;

	/// Returns whether this [Time] is after another [Time].
	bool operator > (Time other) => hour > other.hour ||
		(hour == other.hour && minutes > other.minutes);

	/// Returns whether this [Time] is at or after another [Time].
	bool operator >= (Time other) => this > other || this == other;

	@override 
	String toString() => "$hour:${minutes.toString().padLeft(2, '0')}";
}

/// A range of times.
@immutable
class Range {
	/// When this range starts.
	final Time start;

	/// When this range ends.
	final Time end;

	/// Provides a const constructor.
	const Range (this.start, this.end);

	/// Convenience method for manually creating a range by hand.
	Range.nums (
		int startHour, 
		int startMinute, 
		int endHour, 
		int endMinute
	) : 
		start = Time (startHour, startMinute), 
		end = Time (endHour, endMinute);

	/// Returns a new [Range] from JSON data
	/// 
	/// The json must have `start` and `end` fields 
	/// that map to [Time] JSON objects.
	/// See [Time.fromJson] for more details.
	Range.fromJson(Map<String, dynamic> json) :
		start = Time.fromJson(Map<String, dynamic>.from(json ["start"])),
		end = Time.fromJson(Map<String, dynamic>.from(json ["end"]));

	/// Returns a JSON representation of this range. 
	Map<String, dynamic> toJson() => {
		"start": start.toJson(),
		"end": end.toJson(),
	};

	/// Returns whether [other] is in this range. 
	bool contains (Time other) => start <= other && other <= end;

	@override String toString() => "$start-$end";

	/// Returns whether this range is before another range.
	bool operator < (Time other) => end.hour < other.hour ||
	(
		end.hour == other.hour &&
		end.minutes < other.minutes
	);

	/// Returns whether this range is after another range.
	bool operator > (Time other) => start.hour > other.hour ||
	(
		start.hour == other.hour &&
		start.minutes > other.minutes
	);
}

// /// 
// @immutable
// class SchoolEvent {
// 	// A class to represent the time for a school event
// 	final Range time;
// 	final int year, month, day;
// 	const SchoolEvent ({
// 		@required this.year,
// 		@required this.month,
// 		@required this.day,
// 		@required this.time
// 	});

// 	operator < (DateTime other) => DateTime.utc(  // event is in the past
// 		year, month, day, time.end.hour, time.end.minutes
// 	).isBefore(other);

// 	operator > (DateTime other) => DateTime.utc(  // event is upcoming
// 		year, month, day, time.start.hour, time.start.minutes
// 	).isAfter(other);
// }

/// A description of the time allotment for a day. 
/// 
/// Some days require different time periods, or even periods that 
/// are skipped altogether, as well as homeroom and mincha movements.
/// This class helps facilitate that. 
@immutable
class Special {
	/// The name of this special. 
	final String name;
	
	/// The time allotments for the periods. 
	final List <Range> periods;

	/// The indices of periods to skip. 
	/// 
	/// For example, on fast days, all lunch periods are skipped.
	/// So here, skip would be `[6, 7, 8]`, to skip 6th, 7th and 8th periods.
	final List<int> skip;

	/// The index in [periods] that represents mincha.
	final int mincha;
	
	/// The index in [periods] that represents homeroom.
	final int homeroom;

	/// A const constructor.
	const Special (
		this.name, 
		this.periods, 
		{
			this.homeroom, 
			this.mincha,
			this.skip
		}
	);

	/// Returns a new [Special] from a JSON value. 
	/// 
	/// The value must either be: 
	/// 
	/// - `null`, in which case, `null` will be returned. 
	/// - a string, in which case it should be in the [specials] list, or
	/// - a map, in which case it will be interpreted as JSON. The JSON must have: 
	/// 	- a "name" field, which should be a string. See [name].
	/// 	- a "periods" field, which should be a list of [Range] JSON objects. 
	/// 	- a "homeroom" field, which should be an integer. See [homeroom].
	/// 	- a "skip" field, which should be a list of integers. See [skip].
	/// 
	factory Special.fromJson(dynamic value) {
		if (value == null) {
			return null;
		} else if (value is String) {
			if (!stringToSpecial.containsKey(value)) {
				throw ArgumentError.value(
					value, 
					"Special.fromJson: value",
					"'$value' needs to be one of ${stringToSpecial.keys.join(", ")}"
				);				
			} else {
				return stringToSpecial [value];
			}
		} else if (value is Map) {
			final Map<String, dynamic> json = Map<String, dynamic>.from(value);
			return Special (
				json ["name"],  // name
				[  // list of periods
					for (final dynamic jsonElement in json ["periods"]) 
						Range.fromJson(Map<String, dynamic>.from(jsonElement))
				],
				homeroom: json ["homeroom"],
				mincha: json ["mincha"],
				skip: List<int>.from(json ["skip"]),
			);
		} else {
			throw ArgumentError.value (
				value, // invalid value
				"Special.fromJson: value", // arg name
				"$value is not a valid special", // message
			);
		}
	}

	/// Determines whether to use a Winter Friday or regular Friday schedule. 
	/// 
	/// Winter Fridays mean shorter periods, with an ultimately shorter dismissal.
	static Special getWinterFriday() {
		final DateTime today = DateTime.now();
		final int month = today.month, day = today.day;
		if (month >= Times.schoolStart && month < Times.winterFridayMonthStart) {
			return friday;
		} else if (
			month > Times.winterFridayMonthStart ||
			month < Times.winterFridayMonthEnd
		) {
			return winterFriday;
		} else if (
			month > Times.winterFridayMonthEnd &&
			month <= Times.schoolEnd
		) {
			return friday;
		} else if (month == Times.winterFridayMonthStart) {
			return day < Times.winterFridayDayStart ? friday : winterFriday;
		} else if (month == Times.winterFridayMonthEnd) {
			return day < Times.winterFridayDayEnd ? winterFriday : friday;
		} else {
			// print("Tasked to find winter friday for the summer, assuming regular");
			return friday;
		}
	}

	/// Compares two lists
	/// 
	/// This function is used to compare the [periods] property of two Specials. 
	static bool deepEquals<E>(List<E> a, List<E> b) => 
		(a == null) == (b == null) ||
		(a == null && b == null) &&
		a.length == b.length &&
		<int>[
			for (int index = 0; index < 10; index++) 
				index
		].every(
			(int index) => a [index] == b [index]
		);

	@override 
	String toString() => name;

	@override
	int get hashCode => name.hashCode;

	@override 
	bool operator == (dynamic other) => other is Special && 
		other.name == name &&
		deepEquals<Range>(other.periods, periods) &&
		deepEquals<int>(other.skip, skip) &&
		other.mincha == mincha &&
		other.homeroom == homeroom;

	/// Returns a JSON representation of this Special.
	Map<String, dynamic> toJson() => {
		"periods": [
			for (final Range period in periods) 
				period.toJson()
		],
		"skip": skip,
		"name": name,
		"mincha": mincha,
		"homeroom": homeroom,
	};

	/// The [Special] for Rosh Chodesh.
	static const Special roshChodesh = Special (
		"Rosh Chodesh", 
		[
			Range (Time (8, 00), Time (9, 05)),
			Range (Time (9, 10), Time (9, 50)),
			Range (Time (9, 55), Time (10, 35)),
			Range (Time (10, 35), Time (10, 50)),
			Range (Time (10, 50), Time (11, 30)), 
			Range (Time (11, 35), Time (12, 15)),
			Range (Time (12, 20), Time (12, 55)),
			Range (Time (1, 00), Time (1, 35)),
			Range (Time (1, 40), Time (2, 15)),
			Range (Time (2, 30), Time (3, 00)),
			Range (Time (3, 00), Time (3, 20)),
			Range (Time (3, 20), Time (4, 00)),
			Range (Time (4, 05), Time (4, 45))
		],
		homeroom: 3,
		mincha: 10,
	);

	/// The [Special] for fast days. 
	static const Special fastDay = Special (
		"Tzom",
		[
			Range (Time (8, 00), Time (8, 55)),
			Range (Time (9, 00), Time (9, 35)),
			Range (Time (9, 40), Time (10, 15)),
			Range (Time (10, 20), Time (10, 55)), 
			Range (Time (11, 00), Time (11, 35)), 
			Range (Time (11, 40), Time (12, 15)),
			Range (Time (12, 20), Time (12, 55)), 
			Range (Time (1, 00), Time (1, 35)), 
			Range (Time (1, 35), Time (2, 05))
		],
		mincha: 8,
		skip: [6, 7, 8]
	);

	/// The [Special] for Fridays. 
	static const Special friday = Special (
		"Friday",
		[
			Range (Time (8, 00), Time (8, 45)),
			Range (Time (8, 50), Time (9, 30)),
			Range (Time (9, 35), Time (10, 15)),
			Range (Time (10, 20), Time (11, 00)),
			Range (Time (11, 00), Time (11, 20)),
			Range (Time (11, 20), Time (12, 00)),
			Range (Time (12, 05), Time (12, 45)),
			Range (Time (12, 50), Time (1, 30))
		],
		homeroom: 4
	);

	/// The [Special] for when Rosh Chodesh falls on a Friday. 
	static const Special fridayRoshChodesh = Special (
		"Friday Rosh Chodesh",
		[
			Range(Time (8, 00), Time (9, 05)),
			Range(Time (9, 10), Time (9, 45)),
			Range(Time (9, 50), Time (10, 25)),
			Range(Time (10, 30), Time (11, 05)),
			Range(Time (11, 05), Time (11, 25)),
			Range(Time (11, 25), Time (12, 00)),
			Range(Time (12, 05), Time (12, 40)),
			Range(Time (12, 45), Time (1, 20))
		],
		homeroom: 4
	);

	/// The [Special] for a winter Friday. See [Special.getWinterFriday].
	static const Special winterFriday = Special (
		"Winter Friday",
		[
			Range(Time (8, 00), Time (8, 45)),
			Range(Time (8, 50), Time (9, 25)), 
			Range(Time (9, 30), Time (10, 05)), 
			Range(Time (10, 10), Time (10, 45)),
			Range(Time (10, 45), Time (11, 05)), 
			Range(Time (11, 05), Time (11, 40)),
			Range(Time (11, 45), Time (12, 20)),
			Range(Time (12, 25), Time (1, 00))
		],
		homeroom: 4
	);

	/// The [Special] for when a Rosh Chodesh falls on a Winter Friday.
	static const Special winterFridayRoshChodesh = Special (
		"Winter Friday Rosh Chodesh",
		[
			Range(Time (8, 00), Time (9, 05)),
			Range(Time (9, 10), Time (9, 40)),
			Range(Time (9, 45), Time (10, 15)),
			Range(Time (10, 20), Time (10, 50)), 
			Range(Time (10, 50), Time (11, 10)),
			Range(Time (11, 10), Time (11, 40)),
			Range(Time (11, 45), Time (12, 15)),
			Range(Time (12, 20), Time (12, 50))
		],
		homeroom: 4
	);

	/// The [Special] for when there is an assembly during Homeroom.
	static const Special amAssembly = Special (
		"AM Assembly",
		[
			Range(Time (8, 00), Time (8, 50)),
			Range(Time (8, 55), Time (9, 30)),
			Range(Time (9, 35), Time (10, 10)),
			Range(Time (10, 10), Time (11, 10)),
			Range(Time (11, 10), Time (11, 45)), 
			Range(Time (11, 50), Time (12, 25)),
			Range(Time (12, 30), Time (1, 05)),
			Range(Time (1, 10), Time (1, 45)),
			Range(Time (1, 50), Time (2, 25)),
			Range(Time (2, 30), Time (3, 05)),
			Range(Time (3, 05), Time (3, 25)), 
			Range(Time (3, 25), Time (4, 00)),
			Range(Time (4, 05), Time (4, 45))
		],
		homeroom: 3,

		mincha: 10
	);

	/// The [Special] for when there is an assembly during Mincha.
	static const Special pmAssembly = Special (
		"PM Assembly",
		[
			Range(Time (8, 00), Time (8, 50)), 
			Range(Time (8, 55), Time (9, 30)),
			Range(Time (9, 35), Time (10, 10)),
			Range(Time (10, 15), Time (10, 50)),
			Range(Time (10, 55), Time (11, 30)),
			Range(Time (11, 35), Time (12, 10)),
			Range(Time (12, 15), Time (12, 50)),
			Range(Time (12, 55), Time (1, 30)),
			Range(Time (1, 35), Time (2, 10)), 
			Range(Time (2, 10), Time (3, 30)),
			Range(Time (3, 30), Time (4, 05)),
			Range(Time (4, 10), Time (4, 45))
		],
		mincha: 9
	);

	/// The [Special] for Mondays and Thursdays.
	static const Special regular = Special (
		"M or R day",
		[
			Range(Time (8, 00), Time (8, 50)),
			Range(Time (8, 55), Time (9, 35)),
			Range(Time (9, 40), Time (10, 20)),
			Range(Time (10, 20), Time (10, 35)),
			Range(Time (10, 35), Time (11, 15)), 
			Range(Time (11, 20), Time (12, 00)),
			Range(Time (12, 05), Time (12, 45)),
			Range(Time (12, 50), Time (1, 30)),
			Range(Time (1, 35), Time (2, 15)), 
			Range(Time (2, 20), Time (3, 00)),
			Range(Time (3, 00), Time (3, 20)), 
			Range(Time (3, 20), Time (4, 00)),
			Range(Time (4, 05), Time (4, 45))
		],
		homeroom: 3,
		mincha: 10
	);

	/// The [Special] for Tuesday and Wednesday (letters A, B, and C)
	static const Special rotate = Special (
		"A, B, or C day",
		[
			Range(Time (8, 00), Time (8, 45)), 
			Range(Time (8, 50), Time (9, 30)),
			Range(Time (9, 35), Time (10, 15)),
			Range(Time (10, 15), Time (10, 35)),
			Range(Time (10, 35), Time (11, 15)),
			Range(Time (11, 20), Time (12, 00)),
			Range(Time (12, 05), Time (12, 45)),
			Range(Time (12, 50), Time (1, 30)),
			Range(Time (1, 35), Time (2, 15)),
			Range(Time (2, 20), Time (3, 00)),
			Range(Time (3, 00), Time (3, 20)),
			Range(Time (3, 20), Time (4, 00)),
			Range(Time (4, 05), Time (4, 45))
		],
		homeroom: 3,
		mincha: 10
	);

	/// The [Special] for an early dismissal.
	static const Special early = Special (
		"Early Dismissal",
		[
			Range(Time (8, 00), Time (8, 45)),
			Range(Time (8, 50), Time (9, 25)), 
			Range(Time (9, 30), Time (10, 05)),
			Range(Time (10, 05), Time (10, 20)),
			Range(Time (10, 20), Time (10, 55)),
			Range(Time (11, 00), Time (11, 35)),
			Range(Time (11, 40), Time (12, 15)),
			Range(Time (12, 20), Time (12, 55)),
			Range(Time (1, 00), Time (1, 35)), 
			Range(Time (1, 40), Time (2, 15)),
			Range(Time (2, 15), Time (2, 35)),
			Range(Time (2, 35), Time (3, 10)),
			Range(Time (3, 15), Time (3, 50))
		],
		homeroom: 3,
		mincha: 10
	);

	/// A collection of all the [Special]s
	/// 
	/// Used in the UI
	static const List<Special> specials = [
		regular,
		roshChodesh,
		fastDay,
		friday,
		fridayRoshChodesh,
		winterFriday,
		winterFridayRoshChodesh,
		amAssembly,
		pmAssembly,
		rotate,
		early,
	];

	/// Maps the default special names to their [Special] objects
	static final Map<String, Special> stringToSpecial = Map.fromIterable(
		specials,
		key: (special) => special.name,
	);
}
