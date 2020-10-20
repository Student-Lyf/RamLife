abstract class Service {
	Future<void> init();

	Future<void> signIn();
}

abstract class Database extends Service {
	static const String calendarKey = "calendar";

	Future<bool> get isSignedIn;

	Future<void> signOut();

	/// The user object as JSON
	Future<Map<String, dynamic>> get user;

	/// Changes the user JSON object. 
	Future<void> setUser(Map<String, dynamic> json);

	/// The different classes (sections, not courses) for a schedule.
	Future<Map<String, Map<String, dynamic>>> getSections(Set<String> ids);

	/// Changes the user's classes.
	Future<void> setSections(Map<String, Map<String, dynamic>> json);

	/// The calendar in JSON form. 
	/// 
	/// Admins can change this with [setCalendar]. 
	Future<List<List<Map<String, dynamic>>>> get calendar async => [
		for (int month = 1; month <= 12; month++) [
			for (final dynamic day in (await getCalendarMonth(month)) [calendarKey])
				Map<String, dynamic>.from(day)
		]
	];

	Future<Map<String, dynamic>> getCalendarMonth(int month);

	/// Changes the calendar in the database. 
	/// 
	/// The fact that this method takes a [month] parameter while [calendar] does
	/// not is an indicator that the calendar schema needs to be rewritten. 
	/// 
	/// [month] must be 1-12, not 0-11. 
	/// 
	/// Only admins can change this. 
	Future<void> setCalendar(int month, Map<String, dynamic> json);

	/// The user's reminders. 
	Future<List<Map<String, dynamic>>> get reminders;

	/// Changes the user's reminders. 
	Future<void> setReminders(List<Map<String, dynamic>> json);

	/// The admin object (or null).
	Future<Map<String, dynamic>> get admin;

	/// Sets the admin object for this user.
	Future<void> setAdmin(Map<String, dynamic> json);

	/// The sports games. 
	/// 
	/// Admins can change this with [setSports]. 
	Future<List<Map<String, dynamic>>> get sports;

	/// Changes the sports games (for all users). 
	/// 
	/// Only admins can change this. 
	Future<void> setSports(List<Map<String, dynamic>> json);
}