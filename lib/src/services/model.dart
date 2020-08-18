abstract class Service {
	bool get isReady;

	Future<void> reset();

	Future<void> initialize();

	Future<Map<String, dynamic>> get student;

	Future<Map<String, Map<String, dynamic>>> get sections;

	Future<List<List<Map<String, dynamic>>>> get calendar;
	Future<void> setCalendar(List<List<Map<String, dynamic>>> json);

	Future<List<Map<String, dynamic>>> get reminders;
	Future<void> setReminders(List<Map<String, dynamic>> json);

	Future<Map<String, dynamic>> get admin;
	Future<void> setAdmin(Map<String, dynamic> json);

	Future<List<Map<String, dynamic>>> get sports;
	Future<void> setSports(List<Map<String, dynamic>> json);
}
