import "../../firestore.dart";
import "../user/cloud.dart";

import "interface.dart";

/// Handles reminder data in the cloud.
/// 
/// Reminders are stored in a subcollection of the user document, where each 
/// document has the reminder id as its ID.
class CloudReminders implements RemindersInterface {
	/// The reminders subcollection for this user.
	static CollectionReference get reminders => CloudUser.userDocument
		.collection("reminders");

	@override
	Future<List<Map>> getAll() async {
		final QuerySnapshot snapshot = await reminders.get();
		return [
			for (final QueryDocumentSnapshot document in snapshot.docs)
				document.data()
		];
	}

	@override
	Future<void> set(Map json) => reminders.doc(json ["id"])
		.set(Map<String, dynamic>.from(json));

	@override
	Future<void> delete(String id) => reminders.doc(id).delete();
}
