import "package:cloud_firestore/cloud_firestore.dart";

import "../../auth.dart";
import "../../firestore.dart";

import "interface.dart";

/// Handles user data in the cloud database. 
class CloudUser implements UserInterface {
	/// The users collection in firestore.
	static final CollectionReference users = Firestore.instance
		.collection("students");

	@override
	Future<Map> getUser() => users.doc(Auth.email!)
		.throwIfNull("User not in the database");

	// Users cannot currently edit their own profiles.
	@override 
	Future<void> setUser(Map json) async { }
}
