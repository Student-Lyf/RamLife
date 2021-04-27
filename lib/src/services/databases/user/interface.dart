/// Defines methods for the user profile.
abstract class UserInterface {
	/// The user profile.
	Future<Map> getUser();

	/// Sets the user profile.
	Future<void> setUser(Map json);
}
