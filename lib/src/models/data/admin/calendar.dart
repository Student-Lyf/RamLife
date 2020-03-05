import "dart:async";

import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A data model to manage the calendar. 
/// 
/// This model listens to the calendar and can modify it in the database. 
// ignore: prefer_mixin
class CalendarModel with ChangeNotifier {
	/// How many days there are in every month.
	static const int daysInMonth = 7 * 5;

	/// The current date.
	static final DateTime now = DateTime.now();

	/// The current year.
	static final int currentYear = now.year;

	/// The current month.
	static final int currentMonth = now.month;

	// The raw JSON-filled calendar.
	// final List<List<Map<String, dynamic>>> data = List.filled(12, null);

	/// The calendar filled with [Day]s.
	final List<List<Day>> calendar = List.filled(12, null);

	/// A list of callbacks on the Firebase streams.
	/// 
	/// This list is needed so that the model can cancel the listeners
	/// when the user leaves the page. 
	final List<StreamSubscription> subscriptions = [];

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

	/// A list of calendar paddings for each month. 
	/// 
	/// Every entry is a list of two numbers. The first one is the amount of days
	/// from Sunday before the month starts, and the second one is the amount of 
	/// days after the month until Saturday. They will be represented by blanks. 
	final List<List<int>> paddings = List.filled(12, null);

	/// Creates a data model to hold the calendar.
	/// 
	/// Initializing a [CalendarModel] automatically listens to the calendar in 
	/// Firebase. See [Firestore.getCalendarStream] for details. 
	CalendarModel() {
		for (int month = 0; month < 12; month++) {
			subscriptions.add(
				Firestore.getCalendarStream(month + 1).listen(
					(List<Map<String, dynamic>> cal) {
						calendar [month] = Day.getMonth(cal);
						calendar [month] = layoutMonth(month);
						notifyListeners();
					}
				)
			);
		}
	}

	@override
	void dispose() {
		for (final StreamSubscription subscription in subscriptions) {
			subscription.cancel();
		}
		super.dispose();
	}

	/// Fits the calendar to a 5-day week layout. 
	/// 
	/// Adjusts the calendar so that it begins on the correct day of the week 
	/// (starting on Sunday) instead of defaulting to the first open cell on 
	/// the calendar grid. This function pads the calendar with the correct 
	/// amount of empty days before and after the month. 
	List<Day> layoutMonth(int month) {
		final List<Day> cal = calendar [month];
		final int firstDayOfWeek = DateTime(years [month], month + 1, 1).weekday;
		final int weekday = firstDayOfWeek == 7 ? 0 : firstDayOfWeek - 1;
		paddings [month] = [weekday, daysInMonth - (weekday + cal.length)];
		return cal;
	}

	/// Updates the calendar. 
	Future<void> updateDay(DateTime date, Day day) async {
		calendar [date.month - 1] [date.day - 1] = day;
		await Firestore.saveCalendar(
			date.month - 1, 
			Day.monthToJson(calendar [date.month - 1])
		);
	}
}
