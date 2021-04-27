import "../../idb.dart";

import "interface.dart";

/// Handles reminder data in the on-device database. 
class LocalReminders implements RemindersInterface {
	@override
	Future<List<Map>> getAll() => Idb.instance
		.getAll(Idb.reminderStoreName);

	@override
	Future<void> set(Map json) => Idb.instance.update(
		storeName: Idb.reminderStoreName,
		value: json,
	);

	@override
	Future<void> delete(String id) => Idb.instance.delete(
		storeName: Idb.reminderStoreName,
		key: id,
	);
}
