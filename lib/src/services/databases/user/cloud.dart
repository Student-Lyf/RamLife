import "../../auth.dart";
import "../../firestore.dart";

import "interface.dart";

/// Handles user data in the cloud database. 
class CloudUser implements UserInterface {
	/// The users collection in firestore.
	static final CollectionReference users = Firestore.instance
		.collection("students");

	/// The document for this user.
	static DocumentReference get userDocument => users.doc(Auth.email!);

	@override
	Future<Map> getUser() => userDocument.throwIfNull("User not in the database");

	// Users cannot currently edit their own profiles.
	@override 
	Future<void> setUser(Map json) async { }
}
