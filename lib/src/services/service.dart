/// A data model for services. 
/// 
/// All services must implement this class. It serves two main functions:
/// 
/// - Basic setup: the [isReady], [reset], and [initialize] methods. 
/// - Data model: specifies which data is expected from the service.  
abstract class Service {
	/// Whether this service is ready. 
	/// 
	/// If it's not ready, it was either never set up or misbehaving. 
	/// Call [reset] just in case. 
	Future<bool> get isReady;

	/// Resets the service as if the app were just installed. 
	/// 
	/// While this may delete data from local storage, it should not wipe data
	/// from off-device sources, such as the database. It's sole purpose is to
	/// help the service respond again.
	/// 
	/// [reset] may be called when [isReady] is false, so it should have built-in
	/// error handling.  
	Future<void> reset();

	/// Initializes the service. 
	/// 
	/// After calling this method, [isReady] should return true. 
	/// 
	/// Additionally, there may be other setup needed, that while may not be needed
	/// for the service as a whole, may be done here as well. 
	/// 
	/// Note that this method will be called even when [isReady] is true, so make
	/// make sure this function does not delete user data. 
	Future<void> initialize();

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
	Future<List<List<Map<String, dynamic>>>> get calendar;

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
