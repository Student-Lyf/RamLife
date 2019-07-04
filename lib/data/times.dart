// winter fridays
import "package:flutter/foundation.dart" show required;
import "package:ramaz/mock/times.dart";  // for winter friday times

class Time {
	static const List <int> clock = [
		8, 9, 10, 11, 12, 1, 2, 3, 4, 5
	];

	final int hour, minutes;

	const Time (this.hour, this.minutes);

	factory Time.fromDateTime (DateTime date) {
		int hour = date.hour;
		if (hour >= 17 || hour < 8) hour = 5;  // garbage value
		else if (hour > 12) hour -= 12;
		return Time (hour, date.minute);
	}

	int get hashCode => [hour, minutes].hashCode;

	operator == (dynamic other) => (
		other.runtimeType == Time && 
		other.hour == this.hour && 
		other.minutes == this.minutes
	);

	operator < (Time other) => (
		clock.indexOf (hour) < clock.indexOf (other.hour) || 
		(this.hour == other.hour && this.minutes < other.minutes)
	);
	operator <= (Time other) => this < other || this == other;

	operator > (Time other) => (
		clock.indexOf (hour) > clock.indexOf (other.hour) ||
		(this.hour == other.hour && this.minutes > other.minutes)
	);
	operator >= (Time other) => this > other || this == other;

	@override String toString() => "$hour:${minutes.toString().padLeft(2, '0')}";
}

class Range {
	final Time start, end;
	const Range (this.start, this.end);

	factory Range.nums (int start1, int end1, int start2, int end2) => Range (
		Time (start1, end1), 
		Time (start2, end2),
	);

	bool contains (Time other) => start <= other && other <= end;

	@override String toString() => "$start-$end";

	operator < (Time other) => (
		this.end.hour < other.hour ||
		(
			this.end.hour == other.hour &&
			this.end.minutes < other.minutes
		)
	);

	operator > (Time other) => (
		this.start.hour > other.hour ||
		(
			this.start.hour == other.hour &&
			this.start.minutes > other.minutes
		)
	);
}

class SchoolEvent {
	// A class to represent the time for a school event
	final Range time;
	final int year, month, day;
	const SchoolEvent ({
		@required this.year,
		@required this.month,
		@required this.day,
		@required this.time
	});

	operator < (DateTime other) => DateTime.utc(  // event is in the past
		year, month, day, time.end.hour, time.end.minutes
	).isBefore(other);

	operator > (DateTime other) => DateTime.utc(  // event is upcoming
		year, month, day, time.start.hour, time.start.minutes
	).isAfter(other);
}

class Special {
	final String name;
	final List <Range> periods;
	final List<int> skip;
	final int mincha, homeroom;

	const Special (
		this.name, 
		this.periods, 
		{
			this.homeroom, 
			this.mincha,
			this.skip
		}
	);

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
		} else throw "Cannot get friday schedule for summer month ($month)";
	}

	@override String toString() => name;
	@override operator == (other) => (
		other is Special && 
		other.name == name
	);
}

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

const Special winterFriday = Special (
	"Winter Friday",
	[
		Range(Time (8, 00), Time (9, 45)),
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