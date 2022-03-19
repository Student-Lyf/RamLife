import "package:idb_shim/idb_shim.dart";

import "local_db/idb_factory_stub.dart"
	if (dart.library.io) "local_db/idb_factory_io.dart"
	if (dart.library.html) "local_db/idb_factory_web.dart";

import "service.dart";

/// Helper functions for [ObjectStore].
extension ObjectStoreHelpers on ObjectStore {
	/// Gets the data at the key in this object store.
	Future<Map?> get(Object key) async {
		final dynamic result = await getObject(key);
		return result == null ? null :
			Map.from(result);
	}
}

/// Provides convenience methods on a [Database].
///
/// This extension mostly abstracts details of IDB and handles type-safety.
extension DatabaseHelpers on Database {
	/// Gets data at a key in an object store.
	Future<Map?> get(String storeName, Object key) =>
		transaction(storeName, idbModeReadOnly)
		.objectStore(storeName)
		.get(key);

	/// Gets data from an object store, throwing if it doesn't exist.
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

	/// Sets data in an object store, overwriting if necessary.
	Future<void> update({
		required String storeName,
		required Object value,
		Object? key
	}) => transaction(storeName, idbModeReadWrite)
		.objectStore(storeName)
		.put(value, key);

	/// Deletes an object with the given key from an object store.
	Future<void> delete({
		required String storeName,
		required Object key,
	}) => transaction(storeName, idbModeReadWrite)
		.objectStore(storeName)
		.delete(key);

	/// Deletes all the data in an object store
	Future<void> clearObjectStore(String storeName) =>
		transaction(storeName, idbModeReadWrite)
		.objectStore(storeName)
		.clear();

	/// Gets all the data in an object store.
	Future<List<Map>> getAll(String storeName) async => [
		for (
			final dynamic entry in
			await transaction(storeName, idbModeReadOnly)
				.objectStore(storeName).getAll()
		)	Map.from(entry)
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
/// abstracted by extensions like [DatabaseHelpers] and [ObjectStoreHelpers].
///
/// Another quirk of idb is that object stores can only be created on startup.
/// One way this is relevant is sign-in. If it turns out that the user
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
class Idb extends DatabaseService {
	/// The idb Database object
	static late final Database instance;

	/// The name for the users object store.
	static const String userStoreName = "users";

	/// The name for the sections object store.
	static const String sectionStoreName = "sections";

	/// The name for the calendar object store.
	static const String calendarStoreName = "calendar";

	/// The name for the reminders object store.
	static const String reminderStoreName = "reminders";

	/// The name for the sports object store.
	static const String sportsStoreName = "sports";

	/// The name for the schedules object store.
	static const String scheduleStoreName = "schedules";

	/// The names of all the object stores.
	static const List<String> storeNames = [
		userStoreName,
		sectionStoreName,
		calendarStoreName,
		reminderStoreName,
		sportsStoreName,
		scheduleStoreName,
	];

	@override
	Future<void> init() async {
		final IdbFactory _factory = await idbFactory;
		try {
			instance = await _factory.open(
				"ramlife.db",
				version: 1,
				onUpgradeNeeded: (VersionChangeEvent event) {
					switch(event.oldVersion) {
						case 0: event.database
							..createObjectStore(userStoreName, keyPath: "email")
							..createObjectStore(sectionStoreName, keyPath: "id")
							..createObjectStore(calendarStoreName, keyPath: "month")
							..createObjectStore(reminderStoreName, keyPath: "id")
							..createObjectStore(sportsStoreName, autoIncrement:  true)
							..createObjectStore(scheduleStoreName, keyPath: "name");
					}
				},
			);
		} on StateError {
			await _factory.deleteDatabase("ramlife.db");
			return init();
		}
	}

	@override
	Future<void> signIn() async { }

	@override
	Future<void> signOut() async {
		final Transaction transaction = instance
			.transactionList(storeNames, idbModeReadWrite);

		for (final String storeName in storeNames) {
			await transaction.objectStore(storeName).clear();
		}
	}
}
