import "package:shared_preferences/shared_preferences.dart";

/// An abstraction wrapper around the SharedPreferences plugin.
/// 
/// The SharedPreferences plugin allows for quick and small key-value based
/// storage, which can be very useful. 
class Preferences {
	final SharedPreferences _prefs;

	/// Const constructor for this class.
	const Preferences(this._prefs);

	/// The key for if this is the first time or not.
	static const String firstTimeKey = "firstTime";

	/// The key for the user brightness preference.
	static const String lightMode = "lightMode";

	/// Determines whether this is the first time opening the app.
	bool get firstTime {
		final bool result = _prefs.getBool(firstTimeKey) ?? true;
		_prefs.setBool(firstTimeKey, false);
		return result;
	}

	/// The user's brightness preference. 
	/// 
	/// `true` means light mode, `false` means dark mode, and `null` gets the 
	/// system preferences (if not supported -- light mode).
	bool get brightness => _prefs.getBool(lightMode);
	set brightness (bool value) => _prefs.setBool(lightMode, value); 
}
