/// A collection of dataclasses to sufficiently represent time for a student. 
/// {@category Data}
library time;

import "package:flutter/foundation.dart";
import "package:ramaz/mock.dart";  // for winter friday times

/// The hour and minute representation of a time. 
/// 
/// This is used instead of [Flutter's TimeOfDay](https://api.flutter.dev/flutter/material/TimeOfDay-class.html)
/// to provide the `>` and `<` operators. 
@immutable
class Time {
	/// Defines the order of the hours in terms of the school day. 
	/// 
	/// Numbers on this clock ignore AM and PM by finding their index in this
	/// list instead. Numbers not in this list are considered to be invalid, 
	/// since they are not real school hours. 
	static const List <int> clock = [
		8, 9, 10, 11, 12, 1, 2, 3, 4, 5
	];

	/// The hour in 12-hour format. 
	final int hour;

	/// The minutes. 
	final int minutes;

	/// A const constructor.
	const Time (this.hour, this.minutes);

	/// Simplifies a [DateTime] object to a [Time].
	/// 
	/// If the hour is outside of the values listed in [clock], it is set to 5.
	/// This is to demonstrate that it is after school. 
	/// 
	/// When after-school events are introduced, this should be fixed. 
	factory Time.fromDateTime (DateTime date) {
		int hour = date.hour;
		if (hour >= 17 || hour < 8) hour = 5;  // garbage value
		else if (hour > 12) hour -= 12;
		return Time (hour, date.minute);
	}

	@override
	operator == (dynamic other) => (
		other.runtimeType == Time && 
		other.hour == this.hour && 
		other.minutes == this.minutes
	);

	/// Returns whether this [Time] is before another [Time].
	operator < (Time other) => (
		clock.indexOf (hour) < clock.indexOf (other.hour) || 
		(this.hour == other.hour && this.minutes < other.minutes)
	);

	/// Returns whether this [Time] is at or before another [Time].
	operator <= (Time other) => this < other || this == other;

	/// Returns whether this [Time] is after another [Time].
	operator > (Time other) => (
		clock.indexOf (hour) > clock.indexOf (other.hour) ||
		(this.hour == other.hour && this.minutes > other.minutes)
	);

	/// Returns whether this [Time] is at or after another [Time].
	operator >= (Time other) => this > other || this == other;

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

	/// Returns whether [other] is in this range. 
	bool contains (Time other) => start <= other && other <= end;

	@override String toString() => "$start-$end";

	/// Returns whether this range is before another range.
	operator < (Time other) => (
		this.end.hour < other.hour ||
		(
			this.end.hour == other.hour &&
			this.end.minutes < other.minutes
		)
	);

	/// Returns whether this range is after another range.
	operator > (Time other) => (
		this.start.hour > other.hour ||
		(
			this.start.hour == other.hour &&
			this.start.minutes > other.minutes
		)
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

	/// Determines whether to use a Winter Friday or regular Friday schedule. 
	/// 
	/// Winter Fridays mean shorter periods, with an ultimately shorter dismissal.
	static Special getWinterFriday() {
		final DateTime today = DateTime.now();
		final int month = today.month, day = today.day;
		if (month >= SCHOOL_START && month < WINTER_FRIDAY_MONTH_START)
			return friday;
		else if (
			month > WINTER_FRIDAY_MONTH_START ||
			month < WINTER_FRIDAY_MONTH_END
		) return winterFriday;
		else if (
			month > WINTER_FRIDAY_MONTH_END &&
			month <= SCHOOL_END
		) return friday;
		else if (month == WINTER_FRIDAY_MONTH_START) {
			if (day < WINTER_FRIDAY_DAY_START) return friday;
			else return winterFriday;
		} else if (month == WINTER_FRIDAY_MONTH_END) {
			if (day < WINTER_FRIDAY_DAY_END) return winterFriday;
			else return friday;
		} else {
			print ("Tasked to find winter friday for the summer, assuming regular");
			return friday;
		}
	}

	@override String toString() => name;
	@override operator == (other) => (
		other is Special && 
		other.name == name
	);
}

/// The [Special] for Rosh Chodesh
const Special roshChodesh = Special (
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
const Special fastDay = Special (
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
	skip: const [6, 7, 8]
);

/// The [Special] for Fridays. 
const Special friday = Special (
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
const Special fridayRoshChodesh = Special (
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
const Special winterFriday = Special (
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

/// The [Special] for when a Rosh Chodesh falls on a winter Friday.
const Special winterFridayRoshChodesh = Special (
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
const Special amAssembly = Special (
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
const Special pmAssembly = Special (
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
const Special regular = Special (
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
const Special rotate = Special (
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
const Special early = Special (
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
const List<Special> specials = [
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

final Map<String, Special> stringToSpecial = Map.fromIterable(
	specials,
	key: (special) => special.name,
);

final Map<Special, String> specialToString = Map.fromIterable(
	specials,
	value: (special) => special.name,
);
