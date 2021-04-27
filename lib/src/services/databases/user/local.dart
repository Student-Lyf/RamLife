import "../../auth.dart";
import "../../idb.dart";
import "interface.dart";

/// Handles user data in the local database. 
class LocalUser implements UserInterface {
	@override
	Future<Map> getUser() => Idb.instance.database.throwIfNull(
		storeName: Idb.userStoreName,
		key: Auth.email!,
		message: "User email innaccessible",
	);

	@override
	Future<void> setUser(Map json) => Idb.instance.database
		.add(storeName: Idb.userStoreName, value: json);
}
