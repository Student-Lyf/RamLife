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

import "package:firebase_core/firebase_core.dart";
import "package:shared_preferences/shared_preferences.dart";

import "src/services/auth.dart";
import "src/services/cloud_db.dart";
import "src/services/fcm.dart";
import "src/services/local_db.dart";
import "src/services/preferences.dart";
import "src/services/service.dart";

export "src/services/auth.dart";
export "src/services/cloud_db.dart";
export "src/services/notifications.dart";
export "src/services/preferences.dart";

class Services implements Service {
	/// The singleton instance of this class. 
	static Services instance;

	static Future<void> init() async {
		await Firebase.initializeApp();
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		Services.instance = Services(prefs);
	}

	final Preferences prefs;

	/// Provides a connection to the online database. 
	final CloudDatabase cloudDatabase = CloudDatabase();

	/// The local device storage.
	/// 
	/// Used to minimize the number of requests to the database and keep the app
	/// offline-first. 
	final LocalDatabase localDatabase;

	/// Creates a wrapper around the services. 
	Services(SharedPreferences prefs) : 
		prefs = Preferences(prefs),
		localDatabase = LocalDatabase();

	@override
	Future<bool> get isReady async => await cloudDatabase.isReady 
		&& await localDatabase.isReady;

	@override
	Future<void> reset() async {
		await localDatabase.reset();
		await cloudDatabase.reset();
	}

	@override 
	Future<void> initialize() async {
		await localDatabase.initialize();
		await cloudDatabase.initialize();

		await localDatabase.setUser(await cloudDatabase.user);
		await localDatabase.setSections({});  // to-do later
		await localDatabase.setReminders(await cloudDatabase.reminders);

		await updateSports();
		await updateCalendar();

		if (await Auth.isAdmin) {
			await localDatabase.setAdmin(await cloudDatabase.admin);
		}

		// Register for FCM notifications. 
		// We don't care when this happens
		// ignore: unawaited_futures 
		Future(
			() async {
				await FCM.registerNotifications(
					{
						"refresh": initialize,
						"updateCalendar": updateCalendar,
						"updateSports": updateSports,
					}
				);
				await FCM.subscribeToTopics();
			}
		);
	}

	@override
	Future<Map<String, dynamic>> get user => localDatabase.user;

	@override
	Future<void> setUser(_) async {}  // user cannot modify data

	@override
	Future<Map<String, Map<String, dynamic>>> getSections(Set<String> ids) async {
		Map<String, Map<String, dynamic>> result = 
			await localDatabase.getSections(ids);
		if (result == null) {
			result = await cloudDatabase.getSections(ids);
			await localDatabase.setSections(result);
		}
		return result;
	}

	@override
	Future<void> setSections(_) async {}  // user cannot modify sections

	@override
	Future<List<List<Map<String, dynamic>>>> get calendar => 
		localDatabase.calendar;

	@override
	Future<void> setCalendar(int month, List<Map<String, dynamic>> json) async {
		await cloudDatabase.setCalendar(month, json);
		await localDatabase.setCalendar(month, json);
	}

	@override
	Future<List<Map<String, dynamic>>> get reminders => localDatabase.reminders;

	@override
	Future<void> setReminders(List<Map<String, dynamic>> json) async {
		await cloudDatabase.setReminders(json);
		await localDatabase.setReminders(json);
	}

	@override
	Future<Map<String, dynamic>> get admin => localDatabase.admin;

	@override
	Future<void> setAdmin(Map<String, dynamic> json) async {
		await cloudDatabase.setAdmin(json);
		await localDatabase.setAdmin(json);
	}

	@override
	Future<List<Map<String, dynamic>>> get sports => localDatabase.sports;

	@override
	Future<void> setSports(List<Map<String, dynamic>> json) async {
		await cloudDatabase.setSports(json);
		await localDatabase.setSports(json);
	}

	Future<void> updateCalendar() async {
		for (int month = 1; month <= 12; month++) {
			await localDatabase.setCalendar(month, await cloudDatabase.getMonth(month));
		}
	}

	Future<void> updateSports() async => 
		localDatabase.setSports(await cloudDatabase.sports);
}
