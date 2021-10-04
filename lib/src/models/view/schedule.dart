import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import 'package:ramaz/src/data/schedule/schedule.dart';

/// A view model for the schedule page. 
// ignore: prefer_mixin
class ScheduleViewModel with ChangeNotifier {
	/// The default [Schedule] for the UI.
	Schedule defaultWeekday = Schedule.schedules.firstWhere((schedule) =>
	schedule.name =="Weekday");
	Map<String, Schedule> get defatulSchedule => {
		"Monday":defaultWeekday,
		"Tuesday":defaultWeekday,
		"Wednesday":defaultWeekday,
		"Thursday":defaultWeekday,
		"Friday":Schedule.schedules.firstWhere((schedule) =>
		schedule.name == "Friday"),
	};

	/// The default [Day] for the UI.
	late Day defaultDay;

	/// The schedule data model.
	/// 
	/// Used to retrieve the schedule for a given day.
	final ScheduleModel dataModel;

	/// The day whose schedule is being shown in the UI.
	late Day day;

	/// The selected date from the calendar. 
	/// 
	/// The user can select a date from the calendar and, if there is school 
	/// that day, have their schedule be shown to them.
	DateTime _selectedDay = DateTime.now();

	/// Initializes the view model. 
	/// 
	/// Also initializes the default day shown to the user. 
	/// If today is a school day, then use that. Otherwise, use the 
	/// defaults (see [defatulSchedule]).
	ScheduleViewModel () : dataModel = Models.instance.schedule {
		defaultDay = Day(
			name: Models.instance.user.data.schedule.keys.first, 
			schedule: defatulSchedule[Models.instance.user.data.schedule.keys.first]!
		);
		day = dataModel.today ?? defaultDay;
	}

	/// Attempts to set the UI to the schedule of the given day. 
	/// 
	/// If there is no school on that day, then [ArgumentError] is thrown.
	set date(DateTime date) {
		// Get rid of time
		final DateTime justDate = DateTime.utc (
			date.year, 
			date.month,
			date.day
		);
		final Day? selected = Day.getDate(dataModel.calendar, justDate);
		if (selected == null) {
			throw Exception("No School");
		}
		day = selected;
		_selectedDay = justDate;
		notifyListeners();
	}

	/// Gets the date whose schedule the user is looking at
	DateTime get date => _selectedDay;

	/// Updates the UI to a new day given a new dayName or schedule.
	/// 
	/// If the dayName is non-null, the schedule defaults to [defatulSchedule].
	void update({
		String? newName, 
		Schedule? newSchedule, 
		void Function()? onInvalidSchedule,
	}) {
		final String name = newName ?? day.name;
		final Schedule schedule = newSchedule ?? day.schedule;
		day = Day(name: name, schedule: schedule);
		notifyListeners();
		try {
			// Just to see if the computation is possible. 
			// TODO: Move the logic from ClassList here. 
			Models.instance.schedule.user.getPeriods(day);
		} on RangeError { // ignore: avoid_catching_errors
			day = Day(name: day.name, schedule: defatulSchedule[day.name]!);
			if (onInvalidSchedule != null) {
				onInvalidSchedule();
			}
		}
	}
}
