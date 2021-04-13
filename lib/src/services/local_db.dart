import "package:idb_shim/idb_shim.dart" as idb;

import "auth.dart";
import "database.dart";
import "local_db/idb_factory_stub.dart"
	if (dart.library.io) "local_db/idb_factory_io.dart"
	if (dart.library.html) "local_db/idb_factory_web.dart";

extension <T> on Stream<T> {
  Future<T?> firstWhereOrNull(bool Function(T) test) async {
    await for (final T element in this) {
    	if (test(element)) {
	      return element;
	    }
    }
    return null;
  }
}

/// Provides convenience methods around an [idb.ObjectStore].
extension on idb.ObjectStore {
	/// Gets the data at the key in this object store. 
	/// 
	/// This extension provides type safety. 
	Future<Map?> get(Object key) async {
		final dynamic result = await getObject(key);
		return result == null ? null : 
			Map.from(result); 
	}
}

/// Provides convenience methods on a [Database]. 
extension on idb.Database {
	/// Gets data at a key in an object store. 
	/// 
	/// This code handles transactions so other code doesn't have to. 
	Future<Map?> get(String storeName, Object key) => 
		transaction(storeName, idb.idbModeReadOnly)
		.objectStore(storeName)
		.get(key);

	Future<Map> throwIfNull({
		required String storeName, 
		required Object key, 
		required String message,
	}) async {
		final Map? result = await get(storeName, key);
		if (result == null) {
			throw StateError(message);
		} else {
			return result;
		}
	}

	/// Adds data at a key to an object store. 
	/// 
	/// This code handles transactions so other code doesn't have to. 
	Future<void> add(String storeName, Object value) => 
		transaction(storeName, idb.idbModeReadWrite)
		.objectStore(storeName)
		.add(value);

	/// Updates data in an object store. 
	/// 
	/// This function does not care if the key already exists, it will simply 
	/// update it. 
	/// 
	/// This code can produce unexpected behavior if the object store does not 
	/// have a key. 
	/// 
	/// This code handles transactions so other code doesn't have to. 
	Future<void> update(String storeName, Object value, [Object? key]) => 
		transaction(storeName, idb.idbModeReadWrite)
		.objectStore(storeName)
		.put(value, key);

	/// Gets all the data in an object store. 
	/// 
	/// Also provides strong type safety on those values, treating them like JSON 
	/// objects. This code handles transactions so other code doesn't have to. 
	Future<List<Map>> getAll(String storeName) async => [
		for (
			final dynamic entry in 
			await transaction(storeName, idb.idbModeReadOnly)
				.objectStore(storeName).getAll()
		)	Map.from(entry)
	];

	/// Finds an entry in an object store by a field and value. 
	/// 
	/// Returns null if no key is given. 
	Future<idb.CursorWithValue?> findEntry({
		required String storeName, 
		required String? key, 
		required String path
	}) async => key == null ? null : transaction(storeName, idb.idbModeReadWrite)
		.objectStore(storeName)
		.index(path)
		.openCursor(range: idb.KeyRange.only(key), autoAdvance: true)
		.firstWhereOrNull(
			(idb.CursorWithValue cursor) => cursor.key == key,
		);

	Future<int> objectCount(String storeName) => 
		transaction(storeName, idb.idbModeReadOnly)
		.objectStore(storeName)
		.count();
}

/// A database that's hosted on the user's device. 
/// 
/// On mobile, the database is based on a complex JSON file. On web, the browser
/// has a built-in database called IndexedDb (idb for short). The mobile 
/// implementation is built to match the idb schema. 
/// 
/// In idb, a table is called an "object store". There are two ways of 
/// identifying rows: either by a key (a unique column), or an auto-incrementing
/// value. The choice should be made based on the data in that object store. 
/// 
/// Reading and writing data is done with transactions. This process is 
/// abstracted by extensions on [idb.ObjectStore] and [idb.Database]. 
/// 
/// Another quirk of idb is that object stores can only be created on startup. 
/// One way this is relevant is in [isSignedIn]. If it turns out that the user 
/// is not signed in, it would be too late to create new object stores. That's 
/// why [init] creates new object stores, so that it runs right away. 
/// 
/// Another consequence of having to consolidate object store creation in the 
/// very beginning is that there is a strict way of migrating from one database
/// schema to another. Each database schema has a version number. When the app 
/// starts, the [init] function checks to see what version the database is on.
/// If the code demands a new version, there must be code to create and destroy
/// object stores until the schemas match. The simplest way to do that is by 
/// using a switch statement. A switch statement cascades, meaning the changes
/// from one version to another will follow each other, which should always 
/// lead to an up-to-date schema. 
class LocalDatabase extends Database {
	/// The name for the users object store. 
	static const String userStoreName = "users";

	/// The name for the sections object store. 
	static const String sectionStoreName = "sections";

	/// The name for the calendar object store. 
	static const String calendarStoreName = "calendar";

	/// The name for the reminders object store. 
	static const String reminderStoreName = "reminders";

	/// The name for the admin object store. 
	static const String adminStoreName = "admin";

	/// The name for the sports object store. 
	static const String sportsStoreName = "sports";

	/// The name for the schedules object store.
	static const String scheduleStoreName = "schedules";

	/// All the object stores. 
	/// 
	/// This is used in [signOut] to purge all the data. 
	static const List<String> storeNames = [
		userStoreName, sectionStoreName, calendarStoreName, reminderStoreName,
		adminStoreName, sportsStoreName,
	];

	/// The idb database itself. 
	/// 
	/// Not to be confused with a RamLife [Database]. 
	late idb.Database database;

	@override 
	Future<void> init() async {
		try {
			database = await (await idbFactory).open(
				"ramaz.db",
				version: 3, 
				onUpgradeNeeded: (idb.VersionChangeEvent event) {
					switch(event.oldVersion) {
						case 0: event.database
							..createObjectStore(userStoreName, keyPath: "email")
							..createObjectStore(sectionStoreName, keyPath: "id")
							..createObjectStore(calendarStoreName, keyPath: "month")
							..createObjectStore(reminderStoreName, autoIncrement: true)
							..createObjectStore(adminStoreName, keyPath: "email")
							..createObjectStore(sportsStoreName, autoIncrement:  true);
							continue one;
						one: case 1: event.database
							..deleteObjectStore(reminderStoreName)
							..createObjectStore(reminderStoreName, autoIncrement: true)
								.createIndex("hash", "hash", unique: true);
							continue two;
						two: case 2: event.database
							.createObjectStore(scheduleStoreName, keyPath: "name");
					}
				},
			);
		} on StateError {  // ignore: avoid_catching_errors
			await (await idbFactory).deleteDatabase("ramaz.db");
			await init();
		}
	}

	@override
	Future<void> signIn() async {}

	@override
	bool get isSignedIn => true;

	@override
	Future<void> signOut() async {
		final idb.Transaction transaction = 
			database.transactionList(storeNames, idb.idbModeReadWrite);
		for (final String storeName in storeNames) {
			await transaction.objectStore(storeName).clear();
		}
	}

	@override
	Future<Map> get user => database.throwIfNull(
		storeName: userStoreName, 
		key: Auth.email!, 
		message: "User has not been signed in"
	);

	@override
	Future<void> setUser(Map json) => 
		database.add(userStoreName, json);

	@override
	Future<Map> getSection(String id) => database.throwIfNull(
		storeName: sectionStoreName, 
		key: id,
		message: "Section $id is not recognized",
	);

	@override
	Future<Map<String, Map>?> getSections(
		Iterable<String> ids
	) async => await database.objectCount(sectionStoreName) == 0 ? null 
		: super.getSections(ids);

	@override
	Future<void> setSections(Map<String, Map> json) async {
		for (final Map entry in json.values) {
			await database.add(sectionStoreName, entry);
		}
	} 

	@override
	Future<Map> getCalendarMonth(int month) => 
		database.throwIfNull(
			storeName: calendarStoreName, 
			key: month, 
			message: "Cannot find $month in calendar"
		);

	@override
	Future<List<Map>> getSchedules() => database.getAll(scheduleStoreName);

	@override
	Future<void> saveSchedules(List<Map> schedules) async {
		for (final Map json in schedules) {
			await database.update(scheduleStoreName, json);
		}
	}

	@override
	Future<void> setCalendar(int month, Map json) =>
		database.update(calendarStoreName, json);

	@override
	Future<List<Map>> get reminders => 
		database.getAll(reminderStoreName);

	@override
	Future<void> updateReminder(String? oldHash, Map json) async {
		final idb.CursorWithValue? cursor = await database.findEntry(
			storeName: reminderStoreName, 
			key: oldHash, 
			path: "hash"
		);
		return cursor?.update(json) ?? database
			.transaction(reminderStoreName, idb.idbModeReadWrite)
			.objectStore(reminderStoreName)
			.put(json);
	}

	@override
	Future<void> deleteReminder(dynamic oldHash) async => (
		await database.findEntry(
			storeName: reminderStoreName,
			key: oldHash, 
			path: "hash",
		)
	)?.delete();

	@override
	Future<List<Map>> get sports => 
		database.getAll(sportsStoreName);

	@override
	Future<void> setSports(List<Map> json) async {
		for (final Map entry in json) {
			await database.update(sportsStoreName, entry);
		}
	}
}
