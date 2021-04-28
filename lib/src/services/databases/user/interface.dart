/// Defines methods for the user profile.
abstract class UserInterface {
	/// The user profile.
	Future<Map> getProfile();

	/// Sets the user profile.
	Future<void> setProfile(Map json);
}
