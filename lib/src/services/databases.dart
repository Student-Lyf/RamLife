import "cloud_db.dart";
import "database.dart";
import "local_db.dart";

/// Bundles different databases to provide more complex functionality. 
/// 
/// This class is used to consolidate the results of the online database and
/// the on-device database. It works by downloading all the necessary data in 
/// [signIn]. All reads are from [localDatabase], and all writes are to both 
/// databases. 
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

		// Download this month's calendar, in case it changed
		final int month = DateTime.now().month;
		await localDatabase.setCalendar(
			month, 
			await cloudDatabase.getCalendarMonth(month)
		);
	}

	/// Downloads all the data and saves it to the local database. 
	@override 
	Future<void> signIn() async {
		await cloudDatabase.signIn();
		await localDatabase.signIn();

		await localDatabase.setUser(await cloudDatabase.user);
		await updateCalendar();
		// await updateSports();

		final List<Map> cloudReminders = 
			await cloudDatabase.reminders;
		for (int index = 0; index < cloudReminders.length; index++) {
			await localDatabase.updateReminder(index.toString(), cloudReminders [index]);
		}
	}

	/// Downloads the calendar and saves it to the local database.
	Future<void> updateCalendar() async {
		for (int month = 1; month <= 12; month++) {
			await localDatabase.setCalendar(
				month, await cloudDatabase.getCalendarMonth(month)
			);
		}
		await localDatabase.saveSchedules(await cloudDatabase.getSchedules());
	}

	/// Downloads sports games and saves them to the local database.
	Future<void> updateSports() async {
		await localDatabase.setSports(await cloudDatabase.sports);
	}

	@override 
	bool get isSignedIn => 
		cloudDatabase.isSignedIn && localDatabase.isSignedIn;

	@override
	Future<void> signOut() async {
		await cloudDatabase.signOut();
		await localDatabase.signOut();
	}

	@override
	Future<Map> get user => localDatabase.user;

	// Cannot modify user profile. 
	@override
	Future<void> setUser(Map json) async {} 

	/// Do not use this function. Use [getSections instead]. 
	/// 
	/// In a normal database, the [getSections] function works by calling 
	/// [getSection] repeatedly. So it would be this function that needs to be
	/// overridden. However, this class uses other [Database]s, so instead, 
	/// this function is left blank and [getSections] uses other 
	/// [Database.getSections] to work.
	@override
	Future<Map> getSection(String id) async => {};

	/// Gets section data. 
	/// 
	/// Checks the local database, and downloads it if the data is unavailable.
	@override
	Future<Map<String, Map>> getSections(
		Iterable<String> ids
	) async {
		Map<String, Map>? result = 
			await localDatabase.getSections(ids);
		if (result == null) {
			result = (await cloudDatabase.getSections(ids))!;
			await localDatabase.setSections(result);
		}
		return result;
	}

	// Cannot modify sections
	@override
	Future<void> setSections(Map<String, Map> json) async {}

	@override
	Future<Map> getCalendarMonth(int month) => 
		localDatabase.getCalendarMonth(month);

	@override
	Future<List<Map>> getSchedules() => localDatabase.getSchedules();

	@override
	Future<void> saveSchedules(List<Map> schedules) async {
		await cloudDatabase.saveSchedules(schedules);
		await localDatabase.saveSchedules(schedules);
	}

	@override
	Future<void> setCalendar(int month, Map json) async {
		await cloudDatabase.setCalendar(month, json);
		await localDatabase.setCalendar(month, json);
	}

	@override
	Future<List<Map>> get reminders => localDatabase.reminders;

	@override
	Future<void> updateReminder(dynamic oldHash, Map json) async {
		await cloudDatabase.updateReminder(oldHash, json);
		await localDatabase.updateReminder(oldHash, json);
	}

	@override
	Future<void> deleteReminder(dynamic oldHash) async {
		await cloudDatabase.deleteReminder(oldHash);
		await localDatabase.deleteReminder(oldHash);
	}

	@override
	Future<List<Map>> get sports => localDatabase.sports;

	@override
	Future<void> setSports(List<Map> json) async {
		await cloudDatabase.setSports(json);
		await localDatabase.setSports(json);
	}
}