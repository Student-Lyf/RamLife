import "package:flutter/foundation.dart" show ChangeNotifier, required;

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/preferences.dart";

import "package:ramaz/data/times.dart";
import "package:ramaz/data/schedule.dart";

class ScheduleModel with ChangeNotifier {
	static const Letters defaultLetter = Letters.M;
	static final Special defaultSpecial = regular;
	static const List<Special> fridays = [
		friday, 
		winterFriday, 
		fridayRoshChodesh, 
		winterFridayRoshChodesh
	];


	final Reader reader;
	final Preferences prefs;
	Day day;
	Schedule schedule;
	DateTime selectedDay = DateTime.now();
	List<Period> periods;
	Map<DateTime, Day> calendar;

	ScheduleModel ({
		@required this.reader,
		@required this.prefs,
	}) {
		// Order to determine which day to show:
		// 	Valid day stored in reader? 
		// 		True: use that
		// 		False: Is there school today? 
		// 			True: Use that
		// 			False: Use default day
		final Day readerDay = reader.currentDay;
		if (readerDay == null || !readerDay.school) 
			try {date = selectedDay;}  // try to set today
			on ArgumentError {  // If no school today, go to default
				day = getDay (defaultLetter, defaultSpecial);
			}
		else day = readerDay;
		update();
	}

	static Day getDay (Letters letter, Special special) => Day (
		letter: letter,
		special: special
	);

	set date (DateTime date) {
		// Get rid of time
		final DateTime justDate = DateTime.utc (
			date.year, 
			date.month,
			date.day
		);
		final Day selected = reader.calendar [justDate];
		if (!selected.school) throw ArgumentError("No School");
		reader.currentDay = selected;
		selectedDay = justDate;
		update (newLetter: selected.letter, newSpecial: selected.special);
	}

	void update({Letters newLetter, Special newSpecial}) {
		Letters letter = day.letter;
		Special special = day.special;
		if (newLetter != null) {
			letter = newLetter;
			if (newSpecial == null) {  // set the special again
				switch (letter) {
					case Letters.A: 
					case Letters.B:
					case Letters.C: 
						special = rotate;
						break;
					case Letters.M:
					case Letters.R: 
						special = regular;
						break;
					case Letters.E:
					case Letters.F:
						special = Special.getWinterFriday();
				}
			}
		} 
		if (newSpecial != null) {
			switch (letter) {
				// Cannot set a Friday schedule to a non-Friday
				case Letters.A:
				case Letters.B:
				case Letters.C:
				case Letters.M:
				case Letters.R:
					if (!fridays.contains (newSpecial)) 
						special = newSpecial;
					break;
				// Cannot set a non-Friday schedule to a Friday
				case Letters.E:
				case Letters.F:
					if (fridays.contains (newSpecial))
						special = newSpecial;
			}
		}
		schedule = reader.student.schedule [letter];
		day = getDay (letter, special);
		periods = reader.student.getPeriods(day);
		notifyListeners();
	}
}