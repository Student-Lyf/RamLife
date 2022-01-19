import "dart:async";

import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";

import "schedule.dart";

/// Bundles a [DateTime] with a [Day] to edit the calendar.
class CalendarDay {
	/// The date being represented. 
	final DateTime date;

	/// The school day for the given date. 
	Day? schoolDay;

	/// Bundles a date and a [Day] together.
	CalendarDay({required this.date, required this.schoolDay});
}

/// A model to manage the calendar. 
/// 
/// This model listens to the calendar and can modify it in the database. 
// ignore: prefer_mixin
class CalendarEditor with ChangeNotifier {
	/// How many days there are in every month.
	List<int?> daysInMonth = List.filled(12, null);

	/// The current date.
	static final DateTime now = DateTime.now();

	/// The current year.
	static final int currentYear = now.year;

	/// The current month.
	static final int currentMonth = now.month;

	/// The calendar filled with [Day]s.
	/// 
	/// Each month is lazy-loaded from the database, so it's null until selected.
	final List<List<CalendarDay?>?> calendar = List.filled(12, null);

	/// A list of streams on the Firebase streams.
	final List<StreamSubscription?> subscriptions = List.filled(12, null);

	/// The year of each month.
	/// 
	/// Because the school year goes from September to June, determining the year 
	/// of any given month is not trivial. The year is computed from the current 
	/// month and the month in question. 
	final List<int> years = [
		for (int month = 0; month < 12; month++) 
			currentMonth > 7
				? month > 7 ? currentYear : currentYear + 1
				: month > 7 ? currentYear - 1 : currentYear
	];

	/// Loads the current month to create the calendar.
	CalendarEditor() {
		loadMonth(DateTime.now().month - 1);
	}

	/// Loads a month from the database and pads it accordingly.
	void loadMonth(int month) => subscriptions [month] ??= Services
		.instance.database.firestore.getCalendarStream(month + 1)
		.listen(
			(List<Map?> cal) {
				calendar [month] = layoutMonth(
					[
						for (final Map? day in cal)
							day == null ? null : Day.fromJson(day),
					], 
					month
				);
				notifyListeners();
			}
		);

	@override
	void dispose() {
		for (final StreamSubscription? subscription in subscriptions) {
			subscription?.cancel();
		}
		super.dispose();
	}

	/// Fits the calendar to a 6-week layout. 
	/// 
	/// Adjusts the calendar so that it begins on the correct day of the week 
	/// (starting on Sunday) instead of defaulting to the first open cell on 
	/// the calendar grid. This function pads the calendar with the correct 
	/// amount of empty days before and after the month. 
	List<CalendarDay?> layoutMonth(List<Day?> cal, int month) {
		final int year = years [month];
		final int firstDayOfMonth = DateTime(year, month + 1, 1).weekday;
		final int weekday = firstDayOfMonth == 7 ? 0 : firstDayOfMonth;
		int weeks = 0;  // the number of sundays (except for the first week)
		if (firstDayOfMonth != 7) {  // First week doesn't have a sunday
			weeks++;
		}
		for (int date = 0; date < cal.length; date++) {
			if (DateTime(year, month + 1, date + 1).weekday == 7) {  // Sunday
				weeks++;
			}
		}
		final int leftPad = weekday;
		final int rightPad = (weeks * 7) - (weekday + cal.length);
		return [
			for (int _ = 0; _ < leftPad; _++) null,
			for (int date = 0; date < cal.length; date++) CalendarDay(
				date: DateTime(year, month + 1, date + 1),
				schoolDay: cal [date],
			),
			for (int _ = 0; _ < rightPad; _++) null,
		];
	}

	/// Updates the calendar. 
	Future<void> updateDay({required Day? day, required DateTime date}) async {
		final int index = calendar [date.month - 1]!
			.indexWhere((CalendarDay? day) => day != null);
		calendar [date.month - 1]! [index + date.day - 1]!.schoolDay = day;
		await Services.instance.database.calendar.setMonth(date.month, [
			for (final CalendarDay? day in calendar [date.month - 1]!)
				if (day != null)
					day.schoolDay?.toJson(),
		]);
	}
	/// This function rep
	// Future<void> deleteSchedules(Map<DateTime,Day> days) async  {
	// 	for (MapEntry<DateTime, Day> entry in days.entries){
	// 		entry.value.schedule!=ScheduleViewModel.defatulSchedule[entry.value.name];
	// 		await updateDay(day: entry.value, date: entry.key);
	// 	}
	// }
}
