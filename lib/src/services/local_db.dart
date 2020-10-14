import "package:idb_shim/idb_shim.dart" as idb;

import "auth.dart";  // for user email
import "local_db/idb_factory.dart";  // for platform-specific database
import "service.dart";

/// Provides convenience methods around an [idb.ObjectStore].
extension ObjectExtension on idb.ObjectStore {
	Future<T> get<T>(dynamic key) async => await getObject(key) as T; 
}

/// Provides convenience methods on a [Database]. 
extension DatabaseExtension on idb.Database {
	Future<T> get<T>(String storeName, dynamic key) => 
		transaction(storeName, idb.idbModeReadOnly)
		.objectStore(storeName)
		.get<T>(key);

	Future<void> add<T>(String storeName, T value) => 
		transaction(storeName, idb.idbModeReadWrite)
		.objectStore(storeName)
		.add(value);

	Future<void> update<T>(String storeName, T value) => 
		transaction(storeName, idb.idbModeReadWrite)
		.objectStore(storeName)
		.put(value);

	Future<List<Map<String, dynamic>>> getAll(String storeName) async => [
		for (
			final dynamic entry in 
			await transaction(storeName, idb.idbModeReadOnly)
				.objectStore(storeName).getAll()
		)	Map<String, dynamic>.from(entry)
	];
}

class LocalDatabase extends Database {
	static const String userStoreName = "users";
	static const String sectionStoreName = "sections";
	static const String calendarStoreName = "calendar";
	static const String reminderStoreName = "reminders";
	static const String adminStoreName = "admin";
	static const String sportsStoreName = "sports";

	static const List<String> storeNames = [
		userStoreName, sectionStoreName, calendarStoreName, reminderStoreName,
		adminStoreName, sportsStoreName,
	];

	idb.Database database;

	Future<void> initialize(idb.Database database) async => database
		..createObjectStore(userStoreName, keyPath: "email")
		..createObjectStore(sectionStoreName, keyPath: "id")
		..createObjectStore(calendarStoreName, keyPath: "month")
		..createObjectStore(reminderStoreName, autoIncrement: true)
		..createObjectStore(adminStoreName, keyPath: "email")
		..createObjectStore(sportsStoreName, autoIncrement:  true);

	@override 
	Future<void> init() async => database = await (await idbFactory).open(
		"ramaz.db",
		version: 1, 
		onUpgradeNeeded: (idb.VersionChangeEvent event) {
			switch (event.oldVersion) {
				case 0: // fresh install
					initialize(event.database);
					break;
			}
		}
	);

	@override
	Future<void> signIn() async {}

	@override
	Future<bool> get isSignedIn async => true;

	@override
	Future<void> signOut() async {
		final idb.Transaction transaction = 
			database.transactionList(storeNames, idb.idbModeReadWrite);
		for (final String storeName in storeNames) {
			await transaction.objectStore(storeName).clear();
		}
	}

	@override
	Future<Map<String, dynamic>> get user async => 
		Map<String, dynamic>.from(await database.get(userStoreName, Auth.email));

	@override
	Future<void> setUser(Map<String, dynamic> json) => 
		database.add(userStoreName, json);

	Future<Map<String, dynamic>> getSection(String id) => 
		database.get(sectionStoreName, id);

	@override
	Future<Map<String, Map<String, dynamic>>> getSections(
		Set<String> ids
	) async => {
		for (final String id in ids)
			id: await getSection(id)
	};

	@override
	Future<void> setSections(Map<String, Map<String, dynamic>> json) async {
		for (final Map<String, dynamic> entry in json.values) {
			await database.add(sectionStoreName, entry);
		}
	} 

	@override
	Future<Map<String, dynamic>> getCalendarMonth(int month) =>
		database.get(calendarStoreName, month);

	@override
	Future<void> setCalendar(int month, Map<String, dynamic> json) async {
		await database.update(calendarStoreName, json);
	}

	@override
	Future<List<Map<String, dynamic>>> get reminders => 
		database.getAll(reminderStoreName);

	@override 
	Future<void> setReminders(List<Map<String, dynamic>> json) async {
		for (final Map<String, dynamic> entry in json) {
			await database.update(reminderStoreName, entry);
		}
	}

	@override
	Future<Map<String, dynamic>> get admin async => 
		Map<String, dynamic>.from(await database.get(adminStoreName, Auth.email));

	@override
	Future<void> setAdmin(Map<String, dynamic> json) => 
		database.update(adminStoreName, json);

	@override
	Future<List<Map<String, dynamic>>> get sports => 
		database.getAll(sportsStoreName);

	@override
	Future<void> setSports(List<Map<String, dynamic>> json) async {
		for (final Map<String, dynamic> entry in json) {
			await database.update(sportsStoreName, entry);
		}
	}
}