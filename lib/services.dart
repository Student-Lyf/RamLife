/// An abstraction over device services and data sources. 
/// 
/// The services library serves two purposes: 
/// 
/// 1. To abstract device functions. 
/// 
/// 	For example, device notifications can be abstracted away from the 
/// 	business logic to provide for a platform-agnostic implementation. 
/// 
/// 2. To abstract data sources: 
/// 	
/// 	For example, retrieving data from a database or file can be abstracted
/// 	to keep the app focused on the content of the data rather than how to 
/// 	properly access it. 
/// 
library ramaz_services;

import "src/services/auth.dart";
import "src/services/database.dart";
import "src/services/service.dart";
import "src/services/storage.dart";

export "src/services/auth.dart";
export "src/services/database.dart";
export "src/services/fcm.dart";
export "src/services/notifications.dart";
export "src/services/preferences.dart";

class Services implements Service {
	/// The singleton instance of this class. 
	static Services instance;

	/// Provides a connection to the database. 
	final Database database = Database();

	/// The local device storage.
	/// 
	/// Used to minimize the number of requests to the database and keep the app
	/// offline-first. 
	final Storage storage;

	/// Creates a wrapper around the services. 
	Services(String dir) : storage = Storage(dir);

	@override
	bool get isReady => database.isReady && storage.isReady;

	@override
	Future<void> reset() async {
		await storage.reset();
		await database.reset();
	}

	@override 
	Future<void> initialize() async {
		await storage.initialize();
		await database.initialize();
		if (storage.isReady) {
			return;
		}

		await storage.reset();
		await storage.setUser(await database.user);
		await storage.setSections({});  // to-do later
		await storage.setReminders(await database.reminders);
		await storage.setSports(await database.sports);
		await updateCalendar();

		if (await Auth.isAdmin) {
			await storage.setAdmin(await database.admin);
		}
	}

	@override
	Future<Map<String, dynamic>> get user => storage.user;

	@override
	Future<void> setUser(_) async {}  // user cannot modify data

	@override
	Future<Map<String, Map<String, dynamic>>> getSections(Set<String> ids) async {
		Map<String, Map<String, dynamic>> result = await storage.getSections(ids);
		if (result == null) {
			result = await database.getSections(ids);
			await storage.setSections(result);
		}
		return result;
	}

	@override
	Future<void> setSections(_) async {}  // user cannot modify sections

	@override
	Future<List<List<Map<String, dynamic>>>> get calendar => storage.calendar;

	@override
	Future<void> setCalendar(int month, List<Map<String, dynamic>> json) async {
		await database.setCalendar(month, json);
		await storage.setCalendar(month, json);
	}

	@override
	Future<List<Map<String, dynamic>>> get reminders => storage.reminders;

	@override
	Future<void> setReminders(List<Map<String, dynamic>> json) async {
		await database.setReminders(json);
		await storage.setReminders(json);
	}

	@override
	Future<Map<String, dynamic>> get admin => storage.admin;

	@override
	Future<void> setAdmin(Map<String, dynamic> json) async {
		await database.setAdmin(json);
		await storage.setAdmin(json);
	}

	@override
	Future<List<Map<String, dynamic>>> get sports => storage.sports;

	@override
	Future<void> setSports(List<Map<String, dynamic>> json) async {
		await database.setSports(json);
		await storage.setSports(json);
	}

	Future<void> updateCalendar() async {
		for (int month = 1; month <= 12; month++) {
			await storage.setCalendar(month, await database.getMonth(month));
		}
	}

	Future<void> updateSports() async => 
		storage.setSports(await database.sports);
}
