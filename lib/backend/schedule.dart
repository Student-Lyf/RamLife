import "package:flutter/foundation.dart" show required;

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
		period: period,
		id: data.id
	);

	@override String toString() => "Period $period";

	List <String> getInfo() {
		final List <String> result = ["Time: $time"];
		if (int.tryParse(period) != null) result.add ("Period: $period");
		if (id ==  -1) return result;
		if (room != null) result.add ("Room: $room");
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
			switch (letter) {
				case Letters.A: 
				case Letters.B: 
				case Letters.C: 
					this.special = rotate;
					break;
				case Letters.M: 
				case Letters.R: 
					this.special = regular;
					break;
				case Letters.E: 
				case Letters.F: 
					this.special = Special.getWinterFriday();
			}
		} else this.special = special;
	} 

	int get period {
		final Time time = Time.fromDateTime (today);
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
}

class Lunch {
	final String main, soup, side1, side2, salad, dessert;

	const Lunch ({
		@required this.main, 
		@required this.soup, 
		@required this.side1, 
		@required this.side2,
		@required this.salad, 
		this.dessert = "Seasonal Fresh Fruit"
	});
}

class Schedule {
	final List <PeriodData> periods;
	// final List <int> freePeriods;

	const Schedule (this.periods);

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
