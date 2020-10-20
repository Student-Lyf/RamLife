import "auth.dart";
import "cloud_db.dart";
import "local_db.dart";
import "service.dart";

class Databases extends Database {
	/// Provides a connection to the online database. 
	final CloudDatabase cloudDatabase = CloudDatabase();

	/// The local device storage.
	/// 
	/// Used to minimize the number of requests to the database and keep the app
	/// offline-first. 
	final LocalDatabase localDatabase = LocalDatabase();

	@override
	Future<void> init() async {
		await cloudDatabase.init();
		await localDatabase.init();
	}

	@override 
	Future<void> signIn() async {
		await cloudDatabase.signIn();
		await localDatabase.signIn();

		await localDatabase.setUser(await cloudDatabase.user);
		await localDatabase.setReminders(await cloudDatabase.reminders);
		await updateCalendar();

		if (await Auth.isAdmin) {
			await localDatabase.setAdmin(await cloudDatabase.admin);
		}
	}

	Future<void> updateCalendar() async {
		for (int month = 1; month <= 12; month++) {
			await localDatabase.setCalendar(
				month, 
				await cloudDatabase.getCalendarMonth(month)
			);
		}
	}

	Future<void> updateSports() async {
		await localDatabase.setSports(await cloudDatabase.sports);
	}

	@override 
	Future<bool> get isSignedIn async => 
		(await cloudDatabase.isSignedIn) && (await localDatabase.isSignedIn);

	@override
	Future<void> signOut() async {
		await cloudDatabase.signOut();
		await localDatabase.signOut();
	}

	@override
	Future<Map<String, dynamic>> get user => localDatabase.user;

	@override
	Future<void> setUser(Map<String, dynamic> json) async {} 

	@override
	Future<Map<String, Map<String, dynamic>>> getSections(Set<String> ids) async {
		Map<String, Map<String, dynamic>> result = 
			await localDatabase.getSections(ids);
		if (result.values.every((value) => value == null)) {
			result = await cloudDatabase.getSections(ids);
			await localDatabase.setSections(result);
		}
		return result;
	}

	@override
	Future<void> setSections(
		Map<String, Map<String, dynamic>> json
	) async {}  // user cannot modify sections

	@override
	Future<Map<String, dynamic>> getCalendarMonth(int month) => 
		localDatabase.getCalendarMonth(month);

	@override
	Future<void> setCalendar(int month, Map<String, dynamic> json) async {
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
}