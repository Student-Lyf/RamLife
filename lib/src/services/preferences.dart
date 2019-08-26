import "package:shared_preferences/shared_preferences.dart";

class Preferences {
	final SharedPreferences prefs;
	Preferences(this.prefs);

	// Keys
	static const CALENDAR_UPDATE_KEY = "lastCalendarUpdate";
	static const FIRST_TIME = "firstTime";
	static const LIGHT_MODE = "lightMode";

	// Helper function
	static bool isToday(DateTime other) {
		final DateTime now = DateTime.now();
		return (
			now.year == other.year &&
			now.month == other.month &&
			now.day == other.day
		);
	}

	bool get firstTime {
		final bool result = prefs.getBool(FIRST_TIME) ?? true;
		prefs.setBool(FIRST_TIME, false);
		return result;
	}

	// calendar updates
	bool get shouldUpdateCalendar => firstTime || !isToday (lastCalendarUpdate);
	DateTime get lastCalendarUpdate => DateTime.parse(
		prefs.getString(CALENDAR_UPDATE_KEY)
			?? DateTime.utc (1970, 1, 1).toString() 
	);

	set lastCalendarUpdate (DateTime date) => prefs.setString(
		CALENDAR_UPDATE_KEY, date.toString()
	);

	// Preferred brightness
	bool get brightness => prefs.getBool(LIGHT_MODE);
	set brightness (bool value) => prefs.setBool(LIGHT_MODE, value); 
}
