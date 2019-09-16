import "package:shared_preferences/shared_preferences.dart";

/// An abstraction wrapper around the SharedPreferences plugin.
/// 
/// The SharedPreferences plugin allows for quick and small key-value based
/// storage, which can be very useful. 
class Preferences {
	final SharedPreferences _prefs;

	/// Const constructor for this class.
	const Preferences(this._prefs);

	/// The key for when the calendar was last updated. 
	static const String calendarUpdateKey = "lastCalendarUpdate";

	/// The key for if this is the first time or not.
	static const String firstTimeKey = "firstTime";

	/// The key for the user brightness preference.
	static const String lightMode = "lightMode";

	/// Returns whether a [DateTime] is today.
	static bool isToday(DateTime other) {
		final DateTime now = DateTime.now();
		return (
			now.year == other.year &&
			now.month == other.month &&
			now.day == other.day
		);
	}

	/// Determines whether this is the first time opening the app.
	bool get firstTime {
		final bool result = _prefs.getBool(firstTimeKey) ?? true;
		_prefs.setBool(firstTimeKey, false);
		return result;
	}

	/// Whether the calendar should be updated. 
	/// 
	/// Is true if the app was opened for the first time or 
	/// the calendar was not last updated today.
	bool get shouldUpdateCalendar => firstTime || !isToday (lastCalendarUpdate);

	/// The last time the calendar was updated.
	DateTime get lastCalendarUpdate => DateTime.parse(
		_prefs.getString(calendarUpdateKey)
			?? DateTime.utc (1970, 1, 1).toString() 
	);

	set lastCalendarUpdate (DateTime date) => _prefs.setString(
		calendarUpdateKey, date.toString()
	);

	/// The user's brightness preference. 
	bool get brightness => _prefs.getBool(lightMode);

	set brightness (bool value) => _prefs.setBool(lightMode, value); 
}
