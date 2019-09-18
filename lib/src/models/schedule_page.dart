import "package:flutter/foundation.dart" show ChangeNotifier, required;

import "schedule.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services_collection.dart";

/// A view model for the schedule page. 
class ScheduleModel with ChangeNotifier {
	/// The default [Letters] for the UI.
	static const Letters defaultLetter = Letters.M;

	/// The default [Special] for the UI.
	static const Special defaultSpecial = regular;

	/// The default [Day] for the UI.
	static final Day defaultDay = 
		Day (letter: defaultLetter, special: defaultSpecial);

	/// A list of valid Friday schedules.
	static const List<Special> fridays = [
		friday, 
		winterFriday, 
		fridayRoshChodesh, 
		winterFridayRoshChodesh
	];

	/// The schedule data model.
	/// 
	/// Used to retrieve the schedule for a given day.
	final Schedule schedule;

	/// The day whose schedule is being shown in the UI.
	Day day;

	/// The selected date from the calendar. 
	/// 
	/// The user can select a date from the calendar and, if there is school 
	/// that day, have their schedule be shown to them.
	DateTime selectedDay = DateTime.now();

	/// Initializes the view model. 
	/// 
	/// Also initializes the default day shown to the user. 
	/// If today is a school day, then use that. Otherwise, use the 
	/// defaults (see [defaultLetter] and [defaultSpecial]).
	ScheduleModel ({@required ServicesCollection services}) : 
		schedule = services.schedule
	{
		day = schedule.hasSchool
			? schedule.today
			: defaultDay;
	}

	/// Attempts to set the UI to the schedule of the given day. 
	/// 
	/// If there is no school on that day, then [ArgumentError] is thrown.
	set date (DateTime date) {
		// Get rid of time
		final DateTime justDate = DateTime.utc (
			date.year, 
			date.month,
			date.day
		);
		final Day selected = schedule.calendar [justDate];
		if (!selected.school) throw ArgumentError("No School");
		day = selected;
		selectedDay = justDate;
		update (newLetter: selected.letter, newSpecial: selected.special);
	}

	/// Updates the UI to a new day given a new letter or special.
	/// 
	/// If the letter is non-null, then the special is automatically determined.
	/// See [Day()] for details. 
	/// 
	/// If the special is non-null, then the letter is automatically determined
	/// to avoid setting a Friday schedule to a day that isn't Friday, and vice
	/// versa. See [fridays] for Friday schedules.  
	void update({Letters newLetter, Special newSpecial}) {
		Letters letter = day.letter;
		Special special = day.special;
		if (newLetter != null) {
			letter = newLetter;
			day = Day(letter: letter, special: null);
			notifyListeners();
			return;
		} 
		else if (newSpecial != null) {
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
			day = Day (letter: letter, special: special);
			notifyListeners();
		}
	}
}
