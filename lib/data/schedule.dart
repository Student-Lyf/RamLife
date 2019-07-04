import "package:flutter/foundation.dart" show required;
import "dart:convert" show JsonUnsupportedObjectError;

import "times.dart";

enum Letters {M, R, A, B, C, E, F}

const Map<String, Letters> stringToLetters = {
	"A": Letters.A,
	"B": Letters.B,
	"C": Letters.C,
	"M": Letters.M,
	"R": Letters.R,
	"E": Letters.E,
	"F": Letters.F,
	null: null
};

class Subject {
	final String name, teacher;

	const Subject ({
		@required this.name,
		@required this.teacher
	});

	factory Subject.fromJson(Map<String, dynamic> json) {
		if (json == null) return null;
		final String name = json ["name"], teacher = json ["teacher"];
		if (name == null || teacher == null) 
			throw JsonUnsupportedObjectError (json.toString());
			// throw Error();
		return Subject (
			name: name,
			teacher: teacher,
		);
	}

	static Map<String, Subject> getSubjects(Map<String, Map<String, dynamic>> data) =>
		data.map (
			(String id, Map<String, dynamic> json) => MapEntry (
				id,
				Subject.fromJson(json)
			)
		);

	@override String toString() => "$name ($teacher)";
	@override operator == (dynamic other) => (
		other is Subject && 
		other.name == name &&
		other.teacher == teacher
	);
}

class PeriodData {
	final String room;
	final String id;


	const PeriodData ({
		@required this.room,
		@required this.id
	}) : 
		assert (  // This will only run in dev mode, but whatever
			(room != null && id != null) || (id == null && room == null),
			"Room and id must both be null or not."
		);

	const PeriodData.free() : 
		room = null,
		id = null;

	void fync() {}


	factory PeriodData.fromJson (Map<String, dynamic> json) {
		if (json == null) return null;
		final String room = json ["room"], id = json ["id"];
		if (room == null || id == null) 
			throw JsonUnsupportedObjectError (json);
		return PeriodData(
			room: json ["room"],
			id: json ["id"]
		);
	}

	@override String toString() => "PeriodData ($id, $room)";
	@override operator == (dynamic other) => (
		other is PeriodData &&
		other.id == id &&
		other.room == room
	);
}

class Period {
	final Range time;
	final String room; 
	final String period;
	final String id;

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

	factory Period.mincha (Range time) => Period (
		PeriodData (
			room: null,
			id: null,
		),
		period: "Mincha",
		time: time
	);


	@override String toString() => "Period $period";
	@override operator == (other) => (
		other is Period && 
		other.time == time &&
		other.room == room && 
		other.period == period && 
		other.id == id
	);

	String getName(Subject subject) => 
		int.tryParse (period) != null && id == null
			? "Free period"
			: subject?.name ?? "";


	List <String> getInfo (Subject subject) => [
		"Time: $time",
		if (int.tryParse(period) != null) "Period: $period",
		if (room != null) "Room: $room",
		if (subject != null) "Teacher: ${subject.teacher}",
	];
}

class Day {
	final Letters letter;
	// final Lunch lunch;
	Special special;

	Day ({
		@required this.letter,
		// @required this.lunch,
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

	factory Day.fromJson(Map<dynamic, dynamic> json) {
		if (!json.containsKey("letter")) throw JsonUnsupportedObjectError(json);
		final String jsonLetter = json ["letter"];
		if (!stringToLetters.containsKey (jsonLetter)) 
			throw ArgumentError.value(
				jsonLetter,  // invalid value
				"letter",  // arg name
				"$jsonLetter is not a valid letter"
			);  // message
		final Letters letter = stringToLetters [jsonLetter];
		return Day (
			letter: letter,
			// lunch: null
		);
	}

	static Map<DateTime, Day> getCalendar(Map<String, dynamic> data) {
		final int month = DateTime.now().month;
		final int year = DateTime.now().year;
		final Map<DateTime, Day> result = {};
		for (final MapEntry<String, dynamic> entry in data.entries) {
			final int day = int.parse (entry.key);
			final DateTime date = DateTime.utc(
				year, 
				month, 
				day
			);
			result [date] = Day.fromJson(entry.value);
		}
		return result;
	}

	// @override String toString() => name;
	@override String toString() => "$letter $special";	
	@override operator == (other) => (
		other is Day && 
		other.letter == letter &&
		// other.lunch == lunch &&
		other.special == special
	);

	String get name => letter == null
		? null
		: "${letter.toString().substring (8)} day${
			special == regular || special == rotate ? '' : ' ' + special.name
		}";

	String get n {
		switch (letter) {
			case Letters.A:
			case Letters.E:
			case Letters.M:
			case Letters.R:
			case Letters.F:
				return "n";
			case Letters.B:
			case Letters.C:
			default: 
				return "";
		}
	}

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

	@override String toString() => "Schedule ($periods)";
	@override operator == (other) => throw UnsupportedError(
		"Cannot equate two Schedules. Compare Schedule.periods instead"
	);
		// other is Schedule && ListEquality().equals (other.periods, periods);
		// other is Schedule && other.periods == periods;

	// Each entry is a map: 
	// 	- id: int, 
	// 	- room: String
	// 
	// Also, we can't use typedefs as these are not functions :(

	// The data we receive will come with other data (ints, Strings, etc.)
	// So we have to receive it with dynamic values
	// Here we can cast it to have a FB Map as the value
	factory Schedule.fromJson(List json) => Schedule (
		json.map (
			(dynamic period) => PeriodData.fromJson (
				period?.cast<String, dynamic>()
			)
		).toList()
	);
}
