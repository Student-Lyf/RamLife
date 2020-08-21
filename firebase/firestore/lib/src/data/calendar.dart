import "package:meta/meta.dart";

import "package:firestore/helpers.dart";

import "letters.dart";

/// An extension for [DateTime] to print out the date. 
extension PrettyDatePrinter on DateTime {
	/// Prints the date only.
	String get prettyPrint => "$month-$day-$year";
}

/// A day in the schedule.
@immutable
class Day extends Serializable {
	/// The current year. 
	/// 
	/// Used to determine what year is being referred to in the calendar.
	static final int currentYear = DateTime.now().year;

	/// The current month. 
	/// 
	/// Used to determine what year is being referred to in the calendar.
	static final int currentMonth = DateTime.now().month;

	/// Determines which year [month] is referring to.
	/// 
	/// Uses [currentMonth] and [currentYear].
	static int getYear(int month) => currentMonth > 7
		? month > 7 ? currentYear : currentYear + 1
		: month > 7 ? currentYear - 1 : currentYear;

	/// Maps entries on the calendar to schedules.
	static Map<String, String> specialNames = {
		"rosh chodesh": "Rosh Chodesh",
		"friday r.c.": "Friday Rosh Chodesh",
		"early dismissal": "Early Dismissal",
		"modified": "Modified",
	};

	/// The amound of days in each month.
	/// 
	/// Used in [verifyCalendar].
	static const List<int> daysInMonth = [
		31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
	];

	/// Generates an empty calendar for a given month.
	/// 
	/// This is used for the summer months. 
	static List<Day> getEmptyCalendar(int month) => List.generate(
		31, 
		(int day) => Day(
			letter: null,
			date: DateTime(getYear(month), month, day + 1)
		)
	);

	/// Zips dates, letters, and schedules into [Day] objects.
	/// 
	/// Passes each entry of the three parameters (and [month]) to [Day.raw].
	/// 
	/// [dateLine], [letterLine], and [specialLine] must be the same length.
	static Iterable<Day> getList({
		@required List<String> dateLine,
		@required List<String> letterLine,
		@required List<String> specialLine,
		@required int month,
	}) sync* {
		for (int index = 0; index < dateLine.length; index++) {
			final Day day = Day.raw(
				rawDate: dateLine [index],
				rawLetter: letterLine [index],
				rawSpecial: specialLine [index],
				month: month,
			);
			if (day != null) {
				yield day;
			}
		}
	}

	/// Verifies the calendar by ensuring each day appears in it.
	/// 
	/// If not, logs the missing days as a warning. The return value of this 
	/// function, however, should be treated as an error, and thrown, not logged.
	static bool verifyCalendar(int month, List<Day> calendar) {
		final int daysInThisMonth = daysInMonth [month - 1];
		final Set<int> days = Set.from(
			List.generate(daysInThisMonth + 1, (int day) => day)
		)..remove(0);
		for (final Day day in calendar) {
			days.remove(day?.date?.day);
		}
		final bool result = days.isEmpty && calendar.length == daysInThisMonth;
		// Logs the missing days
		// This is different than the assert since this logs [days] and not [result].
		if (!result) {
			Logger.warning(
				"Calendar for month doesn't have all its days! Missing entries for $days"
			);
		}
		return result;
	}

	/// The date for this day.
	final DateTime date;

	/// The letter for this day.
	final Letter letter;

	/// The special schedule for this day.
	/// 
	/// If null, the app will decide what schedule to use based on its defaults.
	final String special;

	/// Creates a day in the schedule.
	const Day({
		@required this.date, 
		@required this.letter, 
		this.special
	}) : 
		assert (
			letter != null || special == null, 
			"Cannot have a special without a letter: $date"
		);

	/// Parses an entry in the calendar and converts it to a [Day] object.
	/// 
	/// The format of these parameters:
	/// 
	/// - [rawDate] must be able to pass through [int.parse]
	/// - [rawLetter] must be present in [stringToLetter] (eg, "M Day")
	/// - [rawSpecial] can be one of a few things:
	/// 	1. start with "Modified", in which case it will be a modified schedule
	/// 	2. end in " Schedule", and start with something present in [specialNames].
	/// 	3. empty or not present in [specialNames]
	/// 	4. exactly present in [specialNames]
	/// 
	/// [month] and [rawDate] will be used to determine [date], while [rawLetter]
	/// and [rawSpecial] will decide [letter] and [special], respectively.
	factory Day.raw({
		@required String rawDate, 
		@required String rawLetter, 
		@required String rawSpecial,
		@required int month
	}) {
		if (rawDate.isEmpty) {
			return null;
		}
		final int year = getYear(month);
		final int day = int.parse(rawDate);
		final DateTime date = DateTime(year, month, day);
		final String letterString = rawLetter.split(" ") [0];
		final Letter letter = stringToLetter [letterString];
		String special = rawSpecial.toLowerCase();
		if (special.endsWith(" Schedule")) {
			special = special.substring(0, special.indexOf(" Schedule"));
		}
		if (special.startsWith("modified")) {
			special = "Modified";
		} else if (special.isEmpty || !specialNames.containsKey(special)) {
			special = null;
		} else {
			special = specialNames[special];
		}
		return Day(
			date: date,
			letter: letter,
			special: special,
		);
	}

	@override
	String toString() => letter != null 
		? "${date.prettyPrint}: $letter ${special ?? ''}"
		: "${date.prettyPrint}: No School";

	@override
	Map<String, String> get json => {
		"letter": letterToString [letter],
		"special": special,
	};
}