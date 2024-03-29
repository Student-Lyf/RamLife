import "../../auth.dart";
import "../../firestore.dart";
import "../../idb.dart";

import "interface.dart";

/// Handles user data in the cloud database. 
/// 
/// User profiles are saved under the "students" collection where document
/// keys are the user's email, guaranteed to be unique.
/// 
/// Users cannot currently modify their own profiles. Use the Admin SDK instead.
class CloudUser implements UserInterface {
	/// The users collection in firestore.
	static final CollectionReference<Json> users = Firestore.instance
		.collection("students");

	/// The document for this user.
	static DocumentReference<Json> get userDocument => users.doc(Auth.email);

	@override
	Future<Json> getProfile() => userDocument
		.throwIfNull("User not in the database");

	// Users cannot currently edit their own profiles.
	@override 
	Future<void> setProfile(Json json) async { }
}

/// Handles user data in the local database. 
/// 
/// The user is stored as the only record in the user's table.
class LocalUser implements UserInterface {
	@override
	Future<Json> getProfile() => Idb.instance.throwIfNull(
		storeName: Idb.userStoreName,
		key: Auth.email!,
		message: "User email innaccessible",
	);

	@override
	Future<void> setProfile(Json json) => Idb.instance
		.update(storeName: Idb.userStoreName, value: json);
}
