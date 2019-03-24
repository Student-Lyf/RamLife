import "package:flutter/material.dart";
import "times.dart";

class Time {
	static const List <int> clock = [
		8, 9, 10, 11, 12, 1, 2, 3, 4, 5
	];

	final int hour, minutes;

	const Time (this.hour, this.minutes);

	factory Time.fromDateTime (DateTime date) {
		int hour = date.hour;
		if (hour >= 17 || hour < 8) hour = 5;
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

	factory Range.nums (int start1, end1, start2, end2) => Range (
		Time (start1, end1), 
		Time (start2, end2)
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

class Special {
	final String name;
	final List <Range> periods;
	final int mincha, homeroom;

	const Special (
		this.name, 
		this.periods, 
		{
			this.homeroom, 
			this.mincha
		}
	);
}

class Subject {
	final String name, teacher;

	const Subject ({
		@required this.name,
		@required this.teacher
	});
}

class PeriodData {
	final String period, room;
	final int id;

	const PeriodData ({
		@required this.period,
		@required this.room,
		@required this.id
	});

	@override String toString() => "PeriodData $period";
}

class Period {
	final Range time;
	final String room, period;
	final int id;

	const Period._ ({
		@required this.time, 
		@required this.room,
		@required this.period,
		@required this.id,
	});

	factory Period (
		PeriodData data,
		{@required time}
	) => Period._ (
		time: time, 
		room: data.room,
		period: data.period,
		id: data.id
	);

	@override String toString() => "Period $period";

	List <Widget> getInfo() {
		final List <Widget> result = [
			Text (
				"Time: $time",
				textScaleFactor: 1.25
			)
		];
		if (room != null) result.add (
			Text (
				"Room: $room", 
				textScaleFactor: 1.25
			)
		);
		if (int.tryParse(period) != null) result.add (
			Text (
				"Period: $period",
				textScaleFactor: 1.25
			)
		);
		if (id != null) result.add (
			Text (
				"Teacher: ${getSubjectByID (id).teacher}",
				textScaleFactor: 1.25
			)		
		);				
		return result;
	}
}

class Day {
	final Letters letter;
	Special special;
	final Lunch lunch;

	static DateTime today = DateTime.now();

	String get name => "${letter.toString().substring (8)} day ${special.name}";

	Day ({
		@required this.letter,
		@required this.lunch,
		special
	}) {
		if (special == null) {
			if ([Letters.A, Letters.B, Letters.C].contains (letter)) 
				this.special = rotate;
			else if ([Letters.M, Letters.R].contains (letter)) 
				this.special = regular;
			else this.special = getWinterFriday();
		} else this.special = special;
	} 

	int get period {
		final Time time = Time.fromDateTime (today);
		// final Time time = Time (10, 35);
		for (int index = 0; index < special.periods.length; index++) {
			final Range range = special.periods [index];
			if (
				range.contains(time) ||  // during class
				(  // between periods
					index != 0 && 
					special.periods [index - 1] < time && 
					range > time
				)
			) return index;
		}
		return null;
	}

	static Special getWinterFriday() {
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
}

class Lunch {
	final String main, soup, side1, side2, salad, dessert;
	final IconData icon;

	const Lunch ({
		@required this.main, 
		@required this.soup, 
		@required this.side1, 
		@required this.side2,
		@required this.salad, 
		this.icon = Icons.fastfood,
		this.dessert = "Seasonal Fresh Fruit"
	});
}

class Schedule {
	final Letters letter;
	final List <PeriodData> periods;

	const Schedule ({
		@required this.letter,
		@required this.periods
	});

	static Period free (String period, Range time) => Period (
		PeriodData (
			id: null, 
			room: null,
			period: period
		),
		time: time
	);

	static Period homeroom (
		Range time, 
		{String room}
	) => Period (
		PeriodData (
			period: "Homeroom",
			room: room,
			id: null,
		),
		time: time
	);

	static Period mincha (Range time, String room) => Period (
		PeriodData (
			period: "Mincha",
			room: room, 
			id: null,
		),
		time: time
	);
}

class Student {
	final int id;
	final Map <Letters, Schedule> schedule;
	final Letters homeroomDay;
	final String homeroomMeeting;
	final Map <Letters, String> minchaRooms;

	const Student ({
		@required this.id,
		@required this.schedule,
		@required this.homeroomDay,
		@required this.homeroomMeeting,
		@required this.minchaRooms
	});

	List <Period> getPeriods (Day day) {
		final List <Period> result = [];
		final List <PeriodData> periods = schedule [day.letter].periods;
		final Special special = day.special;
		int periodIndex = 0;

		for (int index = 0; index < special.periods.length; index++) {
			final Range range = special.periods [index];
			if (special.homeroom == index) result.add (
				Schedule.homeroom (
					range,
					room: getHomeroomMeeting(day)
				)
			); else if (special.mincha == index) result.add (
				Schedule.mincha (range, minchaRooms [day.letter])
			); else {
				result.add (
					Period (
						periods [periodIndex],
						time: range
					)
				);
				periodIndex++;
			}
		}
		return result;
	}

	String getHomeroomMeeting(Day day) => day.letter == homeroomDay 
		? homeroomMeeting : null;
}

enum Letters {M, R, A, B, C, E, F}