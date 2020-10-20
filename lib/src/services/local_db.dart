import "package:idb_shim/idb_shim.dart" as idb;

import "auth.dart";
import "database.dart";
import "local_db/idb_factory_stub.dart"
	if (dart.library.io) "local_db/idb_factory_io.dart"
	if (dart.library.html) "local_db/idb_factory_web.dart";

/// Provides convenience methods around an [idb.ObjectStore].
extension ObjectStoreExtension on idb.ObjectStore {
	/// Gets the data at the key in this object store. 
	/// 
	/// This extension provides type safety. 
	Future<T> get<T>(dynamic key) async => await getObject(key) as T; 
}

/// Provides convenience methods on a [Database]. 
extension DatabaseExtension on idb.Database {
	/// Gets data at a key in an object store. 
	/// 
	/// This code handles transactions so other code doesn't have to. 
	Future<T> get<T>(String storeName, dynamic key) => 
		transaction(storeName, idb.idbModeReadOnly)
		.objectStore(storeName)
		.get<T>(key);

	/// Adds data at a key to an object store. 
	/// 
	/// This code handles transactions so other code doesn't have to. 
	Future<void> add<T>(String storeName, T value) => 
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
	Future<void> update<T>(String storeName, T value) => 
		transaction(storeName, idb.idbModeReadWrite)
		.objectStore(storeName)
		.put(value);

	/// Gets all the data in an object store. 
	/// 
	/// Also provides strong type safety on those values, treating them like JSON 
	/// objects. This code handles transactions so other code doesn't have to. 
	Future<List<Map<String, dynamic>>> getAll(String storeName) async => [
		for (
			final dynamic entry in 
			await transaction(storeName, idb.idbModeReadOnly)
				.objectStore(storeName).getAll()
		)	Map<String, dynamic>.from(entry)
	];
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
/// abstracted by [ObjectStoreExtension] and [DatabaseExtension]. 
/// 
/// Another quirk of idb is that object stores can only be created on startup. 
/// One way this is relevant is in [isSignedIn]. If it turns out that the user 
/// is not signed in, it would be too late to create new object stores. That's 
/// why the function that creates new object stores ([createObjectStores]) is 
/// called in [init], so that it runs right away. 
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
	idb.Database database;

	/// Creates all the object stores from scratch, specifying their keys. 
	Future<void> createObjectStores(idb.Database database) async => database
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
					createObjectStores(event.database);
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

	@override
	Future<Map<String, dynamic>> getSection(String id) => 
		database.get(sectionStoreName, id);

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