import "package:flutter/foundation.dart" show required;

import "times.dart";

enum Letters {M, R, A, B, C, E, F}

class Subject {
	final String name, teacher;

	const Subject ({
		@required this.name,
		@required this.teacher
	});

	factory Subject.fromJson(Map<String, dynamic> json) => json == null ? null :
		Subject (
			name: json ["name"],
			teacher: json ["teacher"]
		);

	static Map<int, Subject> getSubjects(Map<int, Map<String, dynamic>> data) =>
		data.map (
			(int id, Map<String, dynamic> json) => MapEntry (
				id,
				Subject.fromJson(json)
			)
		);
}

class PeriodData {
	final String room;
	final int id;

	const PeriodData ({
		@required this.room,
		@required this.id
	});

	factory PeriodData.fromJson (Map<String, dynamic> data) => data == null
		? null 
		: PeriodData(
			room: data ["room"],
			id: data ["id"]
		);

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

	List <String> getInfo (Subject subject) {
		final List <String> result = ["Time: $time"];
		if (int.tryParse(period) != null) result.add ("Period: $period");
		if (id ==  -1) return result;
		if (room != null) result.add ("Room: $room");
		if (subject != null) result.add (
			"Teacher: ${subject.teacher}",
		);
		return result;
	}
}

class Day {
	final Letters letter;
	final Lunch lunch;
	Special special;

	String get name => "${letter.toString().substring (8)} day ${
		special == regular || special == rotate ? '' : special.name
	}";

	String get n {
		switch (letter) {
			case Letters.A:
			case Letters.E:
				return "n";
			case Letters.B:
			case Letters.C:
			case Letters.M:
			case Letters.R:
			case Letters.F:
				return "";
		}
		throw "Invalid day: $letter";
	}

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

	factory Day.fromJson(Map<String, dynamic> json) => Day (
		letter: json ["letter"],
		lunch: null
	);

	int get period {
		final Time time = Time.fromDateTime (DateTime.now());
		// final Time time = Time(3, 30);
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
	const Schedule (this.periods);
	factory Schedule.fromJson(List<dynamic> json) {
		// Each entry is a map: 
		// 	- id: int, 
		// 	- room: String
		// 
		// Also, we can't use typedefs as these are not functions :(

		// The data we receive will come with other data (ints, Strings, etc.)
		// So we have to receive it with dynamic values
		// Here we can cast it to have a FB Map as the value
		return Schedule (
			json.map (
				(dynamic period) => PeriodData.fromJson (period?.cast<String, dynamic>())
			).toList()
		);
	}

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
