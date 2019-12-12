/// This library holds dataclasses for various schedule-related data.
/// 
/// Classes here are used to abstract the weird schedule details 
/// to make the code a whole lot simpler. 
library schedule_dataclasses;

import "dart:convert" show JsonUnsupportedObjectError;
import "package:flutter/foundation.dart";

import "times.dart";

/// An enum describing the different letter days.
enum Letters {
	/// An M day at Ramaz
	/// 
	/// Happens every Monday
	M, 

	/// An R day at Ramaz.
	/// 
	/// Happens every Thursday.
	R, 

	/// A day at Ramaz.
	/// 
	/// Tuesdays and Wednesdays rotate between A, B, and C days.
	A, 

	/// B day at Ramaz.
	/// 
	/// Tuesdays and Wednesdays rotate between A, B, and C days.
	B, 

	/// C day at Ramaz.
	/// 
	/// Tuesdays and Wednesdays rotate between A, B, and C days.
	C, 

	/// E day at Ramaz.
	/// 
	/// Fridays rotate between E and F days.
	E, 

	/// F day at Ramaz.
	/// 
	/// Fridays rotate between E and F days.
	F
}

/// Maps a [Letters] to a [String] without a function.
const Map<Letters, String> lettersToString = {
	Letters.A: "A",
	Letters.B: "B",
	Letters.C: "C",
	Letters.M: "M",
	Letters.R: "R",
	Letters.E: "E",
	Letters.F: "F",
};

/// Maps a [String] to a [Letters] without a function.
const Map<String, Letters> stringToLetters = {
	"A": Letters.A,
	"B": Letters.B,
	"C": Letters.C,
	"M": Letters.M,
	"R": Letters.R,
	"E": Letters.E,
	"F": Letters.F,
	null: null,
};

/// A subject, or class, that a student can take.
/// 
/// Since one's schedule contains multiple instances of the same subject,
/// subjects are represented externally by an ID, which is used to look up
/// a canonicalized [Subject] instance. This saves space and simplifies
/// compatibility with existing school databases. 
@immutable
class Subject {
	/// Returns a map of [Subject]s from a list of JSON objects.
	/// 
	/// The keys are IDs to the subject, and the values are the
	/// corresponding [Subject] instances.
	/// See [Subject.fromJson] for more details. 
	static Map<String, Subject> getSubjects(
		Map<String, Map<String, dynamic>> data
	) => data.map (
		(String id, Map<String, dynamic> json) => MapEntry (
			id,
			Subject.fromJson(json)
		)
	);

	/// The name of this subject.
	final String name;
	
	/// The teacher who teaches this subject.
	final String teacher;

	/// A const constructor for a [Subject].
	const Subject ({
		@required this.name,
		@required this.teacher
	});

	/// Returns a [Subject] instance from a JSON object. 
	/// 
	/// The JSON map must have a `teacher` and `name` field.
	Subject.fromJson(Map<String, dynamic> json) :
		name = json ["name"], 
		teacher = json ["teacher"] 
	{
		if (name == null || teacher == null) {
			throw JsonUnsupportedObjectError (json.toString());
		}
	}

	@override 
	String toString() => "$name ($teacher)";
		
	@override 
	int get hashCode => "$name-$teacher".hashCode;

	@override 
	bool operator == (dynamic other) => other is Subject && 
		other.name == name &&
		other.teacher == teacher;
}

/// A representation of a period, independent of the time. 
/// 
/// This is needed since the time can change on any day.
/// See [Special] for when the times can change.
@immutable
class PeriodData {
	/// Returns a list of [PeriodData] from a JSON object.
	/// 
	/// Note that some entries in the list may be null.
	/// They represent a free period in the schedule.
	/// See [PeriodData.fromJson] for more details.
	static List<PeriodData> getList(List json) => [
		for (final dynamic periodJson in json)
			periodJson == null ? null : 
				PeriodData.fromJson(Map<String, dynamic>.from(periodJson))
	];

	/// The room the student needs to be in for this period.
	final String room;

	/// The id for this period's subject.
	/// 
	/// See the [Subject] class for more details.
	final String id;

	/// A const constructor for a [PeriodData]. 
	/// 
	/// If both [id] and [room] are null, then it is a free period.
	/// Use [PeriodData.free] instead. Otherwise, it is considered an error
	/// to have a null [room] OR [id].
	const PeriodData ({
		@required this.room,
		@required this.id
	}) : 
		assert (
			room != null || id != null,
			"Room and id must both be null or not."
		);

	const PeriodData._free() : 
		room = null,
		id = null;

	/// A free period.
	/// 
	/// Use this instead of manually constructing a [PeriodData] 
	/// to keep consistency throughtout the code. 
	static const free = PeriodData._free();

	/// Returns a [PeriodData] from a JSON object.
	/// 
	/// If the JSON object is null, then it is considered a free period.
	/// Otherwise, both `json ["room"]` and `json ["id"]` must be non-null.
	factory PeriodData.fromJson (Map<String, dynamic> json) => json == null
		? PeriodData.free
		: PeriodData(
			room: json ["room"],
			id: json ["id"]
		);

	@override 
	String toString() => "PeriodData ($id, $room)";

	@override 
	int get hashCode => "$room-$id".hashCode;

	@override 
	bool operator == (dynamic other) => other is PeriodData &&
		other.id == id &&
		other.room == room;
}

/// A representation of a period, including the time it takes place. 
/// 
/// Period objects unpack the [PeriodData] passed to them,
/// so that they alone contain all the information to represent a period.
@immutable
class Period {
	/// The time this period takes place. 
	/// 
	/// If the time is not known (ie, the schedule is [Special.modified]), 
	/// then this will be null. 
	final Range time;

	/// The room this period is in.
	/// 
	/// It may be null, indicating that the student is not expected to be in class.
	/// 
	/// Since the room comes from a [PeriodData] object, both the room and [id] 
	/// must both be null, or both must be non-null. See [PeriodData()] for more.
	final String room; 

	/// A String representation of this period. 
	/// 
	/// Since a period can be a number (like 9), or a word (like "Homeroom"),
	/// String was chosen to represent both. This means that the app does not 
	/// care whether a period is a regular class or something like homeroom.
	final String period;

	/// The id of the [Subject] for this period. 
	/// 
	/// It may be null, indicating that the student is not expected 
	/// to be in a class at this time. 
	/// 
	/// Since the id comes from a [PeriodData] object, both the id and [room] 
	/// must both be null, or both must be non-null. See [PeriodData()] for more.
	final String id;

	/// Unpacks a [PeriodData] object and returns a Period. 
	Period(
		PeriodData data,
		{@required this.time, @required this.period}
	) : 
		room = data.room,
		id = data.id;

	/// Returns a period that represents time for Mincha. 
	/// 
	/// Use this constructor to keep a consistent definition of "Mincha".
	const Period.mincha(this.time) :
		room = null,
		id = null,
		period = "Mincha";

	/// This is only for debug purposes. Use [getName] for UI labels.
	@override 
	String toString() => "Period $period";

	@override
	int get hashCode => "$period-$id".hashCode;
	
	@override 
	bool operator == (dynamic other) => other is Period && 
		other.time == time &&
		other.room == room && 
		other.period == period && 
		other.id == id;

	/// Returns a String representation of this period. 
	/// 
	/// The expected subject can be retrieved by looking up the [id].
	/// 
	/// If [period] is an integer and [id] is null, then it is a free period.
	/// Otherwise, if [period] is not a number, than it is returned instead.
	/// Finally, the [Subject] that corresponds to [id] will be returned.
	/// 
	/// For example: 
	/// 
	/// 1. A period with [PeriodData.free] will return "Free period"
	/// 2. A period with `period == "Homeroom"` will return "Homeroom"
	/// 3. A period with `period == "3"` will return the name of the [Subject].
	/// 
	String getName(Subject subject) => int.tryParse(period) != null && id == null
		? "Free period"
		: subject?.name ?? period;

	/// Returns a list of descriptions for this period. 
	/// 
	/// The expected subject can be retrieved by looking up the [id].
	/// 
	/// Useful throughout the UI. This function will: 
	/// 
	/// 1. Always display the time.
	/// 2. If [period] is a number, will display the period.
	/// 3. If [room] is not null, will display the room.
	/// 4. If [id] is valid, will return the name of the [Subject].
	/// 
	List <String> getInfo (Subject subject) => [
		if (time != null) "Time: $time",
		if (int.tryParse(period) != null) "Period: $period",
		if (room != null) "Room: $room",
		if (subject != null) "Teacher: ${subject.teacher}",
	];
}

/// A day at Ramaz. 
/// 
/// Each day has a [letter] and [special] property.
/// The [letter] property decides which schedule to show,
/// while the [special] property decides what time slots to give the periods. 
@immutable
class Day {
	/// The default [Special] for a given [Letters].
	/// 
	/// See [Special.getWinterFriday] for how to determine the Friday schedule.
	static final Map<Letters, Special> specials = {
		Letters.A: Special.rotate,
		Letters.B: Special.rotate,
		Letters.C: Special.rotate,
		Letters.M: Special.regular,
		Letters.R: Special.regular,
		Letters.E: Special.getWinterFriday(),
		Letters.F: Special.getWinterFriday(),
	};

	/// Parses the calendar from a JSON map.
	/// 
	/// The key is the date (defaulting to today's month), 
	/// and the value is a JSON representation of a [Day].
	/// 
	/// See [Day.fromJson] for details on how a [Day] looks in JSON
	// static Map<DateTime, Day> getCalendar(Map<String, dynamic> data) {
	static Map<DateTime, Day> getCalendar(List data) {
		final DateTime now = DateTime.now();
		final int month = now.month;
		final int year = now.year;
		final Map<DateTime, Day> result = {};
		for (final MapEntry<int, dynamic> entry in data.asMap().entries) {
			final int day = entry.key + 1;
			final DateTime date = DateTime.utc(
				year, 
				month, 
				day
			);
			result [date] = Day.fromJson(entry.value);
		}
		return result;
	}

	/// The letter of this day. 
	/// 
	/// This decides which schedule of the student is shown. 
	final Letters letter;

	/// The time allotment for this day.
	/// 
	/// See the [Special] class for more details.
	final Special special;

	/// Returns a new Day from a [Letters] and [Special].
	/// 
	/// [special] can be null, in which case [specials] will be used.
	Day ({
		@required this.letter,
		special
	}) : special = special ?? specials [letter];

	/// Returns a Day from a JSON object.
	/// 
	/// `json ["letter"]` must be one of the specials in [Special.stringToSpecial].
	/// `json ["letter"]` must not be null.
	/// 
	/// `json ["special"]` may be: 
	/// 
	/// 1. One of the specials from [specials].
	/// 2. JSON of a special. See [Special.fromJson].
	/// 3. null, in which case [specials] will be used.
	/// 
	/// This factory is not a constructor so it can dynamically check 
	/// for a valid [letter] while keeping the field final.
	factory Day.fromJson(Map<dynamic, dynamic> json) {
		if (!json.containsKey("letter")) {
			throw JsonUnsupportedObjectError(json);
		}
		final String jsonLetter = json ["letter"];
		final jsonSpecial = json ["special"];
		if (!stringToLetters.containsKey (jsonLetter)) {
			throw ArgumentError.value(
				jsonLetter,  // invalid value
				"letter",  // arg name
				"$jsonLetter is not a valid letter",  // message
			); 
		}
		final Letters letter = stringToLetters [jsonLetter];
		final Special special = Special.fromJson(jsonSpecial);
		return Day (letter: letter, special: special);
	}

	@override 
	String toString() => name;

	@override
	int get hashCode => name.hashCode;

	@override 
	bool operator == (dynamic other) => other is Day && 
		other.letter == letter &&
		// other.lunch == lunch &&
		other.special == special;

	/// Returns a JSON representation of this Day. 
	/// 
	/// Will convert [special] to its name if it is a built-in special.
	/// Otherwise it will convert it to JSON form. 
	Map<String, dynamic> toJson() => {
		"letter": lettersToString [letter],
		"special": special == null ? null : 
			Special.stringToSpecial.containsKey(special.name)
				? special.name
				: special.toJson()
	};

	/// A human-readable string representation of this day.
	/// 
	/// If the letter is null, returns null. 
	/// Otherwise, returns [letter] and [special].
	/// If [special] was left as the default, will only return the [letter].
	String get name => letter == null
		? null
		: "${lettersToString [letter]} day${
			special == Special.regular || special == Special.rotate 
				? '' : ' ${special.name}'
		}";

	/// Whether to say "a" or "an".
	/// 
	/// This method is needed since [letter] is a letter and not a word. 
	/// So a letter like "R" might need "an" while "B" would need "a".
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

	/// Whether there is school on this day.
	bool get school => letter != null;

	/// Whether the times for this day are known.
	bool get isModified => special == Special.modified;

	/// The period right now. 
	/// 
	/// Uses [special] to calculate the time slots for all the different periods,
	/// and uses [DateTime.now()] to look up what period it is right now. 
	/// 
	/// See [Time] and [Range] for implementation details.
	int get period {
		final Time time = Time.fromDateTime (DateTime.now());
		for (int index = 0; index < (special.periods?.length ?? 0); index++) {
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

// class Lunch {
// 	final String main, soup, side1, side2, salad, dessert;

// 	const Lunch ({
// 		@required this.main, 
// 		@required this.soup, 
// 		@required this.side1, 
// 		@required this.side2,
// 		@required this.salad, 
// 		this.dessert = "Seasonal Fresh Fruit"
// 	});
// }
