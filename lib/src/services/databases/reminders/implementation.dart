import "../../firestore.dart";
import "../../idb.dart";

import "../user/implementation.dart";

import "interface.dart";

/// Handles reminder data in the cloud.
/// 
/// Reminders are stored in a subcollection of the user document, where each 
/// document has the reminder id as its ID.
class CloudReminders implements RemindersInterface {
	/// The reminders subcollection for this user.
	static CollectionReference<Json> get reminders => CloudUser.userDocument
		.collection("reminders");

	@override
	Future<List<Json>> getAll() => reminders.getAll();

	@override
	Future<void> set(Json json) => reminders.doc(json ["id"])
		.set(Json.from(json));

	@override
	Future<void> delete(String id) => reminders.doc(id).delete();

	/// Generates a random ID.
	String getId() => reminders.doc().id;
}

/// Handles reminder data in the on-device database. 
/// 
/// Reminders are stored in an object store where the keypath is `id`. 
class LocalReminders implements RemindersInterface {
	@override
	Future<List<Json>> getAll() => Idb.instance.getAll(Idb.reminderStoreName);

	@override
	Future<void> set(Json json) => Idb.instance.update(
		storeName: Idb.reminderStoreName,
		value: json,
	);

	@override
	Future<void> delete(String id) => Idb.instance.delete(
		storeName: Idb.reminderStoreName,
		key: id,
	);
}
