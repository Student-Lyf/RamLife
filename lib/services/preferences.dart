import "package:shared_preferences/shared_preferences.dart";

class Preferences {
	final SharedPreferences prefs;
	Preferences(this.prefs);

	// Keys
	static const CALENDAR_UPDATE_KEY = "lastCalendarUpdate";

	// Helper function
	static bool isToday(DateTime other) {
		final DateTime now = DateTime.now();
		return (
			now.year == other.year &&
			now.month == other.month &&
			now.day == other.day
		);
	}

	// calendar updates
	bool get shouldUpdateCalendar => !isToday (lastCalendarUpdate);
	DateTime get lastCalendarUpdate => DateTime.parse(
		prefs.getString(CALENDAR_UPDATE_KEY)
	);
}