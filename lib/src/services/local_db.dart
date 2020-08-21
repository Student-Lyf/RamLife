import "package:idb_shim/idb_shim.dart";

import "auth.dart";  // for user email
import "local_db/idb_factory.dart";  // for platform-specific database
import "service.dart";

/// Provides convenience methods around an [ObjectStore].
extension ObjectExtension on ObjectStore {
	Future<T> get<T>(dynamic key) async => await getObject(key) as T; 
}

/// Provides convenience methods on a [Database]. 
extension DatabaseExtension on Database {
	Future<T> get<T>(String storeName, dynamic key) => 
		transaction(storeName, idbModeReadOnly)
		.objectStore(storeName)
		.get<T>(key);

	Future<void> add<T>(String storeName, T value) => 
		transaction(storeName, idbModeReadWrite)
		.objectStore(storeName)
		.add(value);

	Future<void> update<T>(String storeName, T value) => 
		transaction(storeName, idbModeReadWrite)
		.objectStore(storeName)
		.put(value);

	Future<List<Map<String, dynamic>>> getAll(String storeName) async => [
		await for (
			final CursorWithValue cursor in transaction(storeName, idbModeReadOnly)
				.objectStore(storeName)
				.openCursor(autoAdvance: true)
		) Map<String, dynamic>.from(cursor.value)
	];
}

class LocalDatabase implements Service {
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

	Database database;

	@override
	Future<bool> get isReady async {
		database = await (await idbFactory).open(
			"ramaz.db",
			version: 1, 
			onUpgradeNeeded: (VersionChangeEvent event) {
				database = event.database;  // for access within [initialize].
				switch (event.oldVersion) {
					case 0: // fresh install
						initialize();
						break;
				}
			}
		);
		return true;  // if it weren't ready there would be an error
	}

	/// Initializes the database. 
	/// 
	/// Simply opening the database is async, so that is done in [isReady], since 
	/// it is needed to initialize the service. However, modifying the database
	/// is only allowed within [IdbFactory.open], so it cannot be held off until
	/// login. Hence, this function should be omitted from the global service 
	/// manager's [initialize] function, and should instead be called from 
	/// within [isReady] (which is allowed, since it is async). 
	/// 
	/// Additionally, since the data itself is only provided in the service 
	/// manager's [initialize] function, this function doesn't have to worry about
	/// retrieving data so much as structuring it.  
	@override
	Future<void> initialize() async => database
		..createObjectStore(userStoreName, keyPath: "email")
		..createObjectStore(sectionStoreName, keyPath: "id")
		..createObjectStore(calendarStoreName, keyPath: "month")
		..createObjectStore(reminderStoreName, autoIncrement: true)
		..createObjectStore(adminStoreName, keyPath: "email")
		..createObjectStore(sportsStoreName, autoIncrement:  true);

	@override
	Future<void> reset() async {
		final Transaction transaction = 
			database.transactionList(storeNames, idbModeReadWrite);
		for (final String storeName in storeNames) {
			await transaction.objectStore(storeName).clear();
		}
	}

	@override
	Future<Map<String, dynamic>> get user => 
		database.get(userStoreName, Auth.email);

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

	Future<List<Map<String, dynamic>>> getMonth(int month) async {
		final Map<String, dynamic> json = 
			await database.get(calendarStoreName, month);
		return [
			for (final dynamic entry in json ["calendar"])
				Map<String, dynamic>.from(entry)
		];
	}

	@override
	Future<List<List<Map<String, dynamic>>>> get calendar async => [
		for (int month = 1; month <= 12; month++)
			await getMonth(month)
	];

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
	Future<Map<String, dynamic>> get admin => 
		database.get(adminStoreName, Auth.email);

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