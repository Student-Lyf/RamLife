import "package:ramaz/data.dart";
export "package:ramaz/data.dart";

/// Defines methods for the user profile.
abstract class UserInterface {
	/// The user profile.
	Future<Json> getProfile();

	/// Sets the user profile.
	Future<void> setProfile(Json json);
}
