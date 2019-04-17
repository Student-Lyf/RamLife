import "package:flutter/foundation.dart" show required;
import "package:flutter/material.dart" show IconData, Icons;

import "times.dart";
import "../mock.dart";  // for winter friday start and end times

enum Letters {M, R, A, B, C, E, F}

class Subject {
	final String name, teacher;

	const Subject ({
		@required this.name,
		@required this.teacher
	});
}

class PeriodData {
	final String room;
	final int id;

	const PeriodData ({
		@required this.room,
		@required this.id
	});

	@override String toString() => "PeriodData $id";
}

class Period {
	final Range time;
	final String room; 
	final String period;
	final int id;

	const Period._ ({
		@required this.time, 
		@required this.room,
		@required this.period,
		@required this.id,
	});

	factory Period (
		PeriodData data,
		{@required Range time, @required String period}
	) => Period._ (
		time: time, 
		room: data.room,
		// period: data.period,
		period: period,
		id: data.id
	);

	@override String toString() => "Period $period";

	List <String> getInfo() {
		final List <String> result = ["Time: $time"];
		if (room != null) result.add ("Room: $room");
		if (int.tryParse(period) != null) result.add ("Period: $period");
		if (id != null) result.add (
				"Teacher: ${getSubjectByID (id).teacher}",
		);
		return result;
	}
}

class Day {
	final Letters letter;
	Special special;
	final Lunch lunch;

	static DateTime today = DateTime.now();

	String get name => "${letter.toString().substring (8)} day ${
		special == regular || special == rotate ? '' : special.name
	}";

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
	final List <PeriodData> periods;
	final List <int> freePeriods;

	const Schedule (this.periods, {this.freePeriods = const []});

	static Period homeroom (
		Range time, 
		{String room}
	) => Period (
		PeriodData (
			room: room,
			id: null,
		),
		period: "Homeroom",
		time: time
	);

	static Period mincha (Range time, String room) => Period (
		PeriodData (
			room: room, 
			id: null,
		),
		period: "Mincha",
		time: time
	);
}
