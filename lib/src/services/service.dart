/// A Service that interacts with third-party code. 
/// 
/// A service can be defined as a plugin which needs special code to interact
/// with, independent of the functionality of the service. For example, 
/// authentication needs a lot of extra code, before you even get into the 
/// details like sign-in providers and UI flow. 
/// 
/// This class is abstract and provides a structure to all services, which 
/// should inherit from it. There are two functions that provide convenient
/// hooks for managing the life cycle of the service. 
/// 
/// The first one is the [init] function. The init function should contain code
/// that needs to be run when the app starts, whether or not the user is signed
/// in. 
/// 
/// The other function is the [signIn] function. The signIn function should 
/// contain code that needs to be run when the user signs into the app. One
/// example can be notifications that need to request permissions when the 
/// user logs in. 
/// 
/// Other than the [signIn] function, services should not care (or know) whether
/// the user is signed in or not. 
abstract class Service {
	/// Initializes the service. 
	/// 
	/// Override this function with code that needs to be run when the app starts. 
	/// A good use for this is registering with plugins that return a Future. 
	Future<void> init();

	/// A callback that runs when the user signs in. 
	/// 
	/// Override this function with code that facilitates the sign-in process. 
	Future<void> signIn();
}

/// A service specific to databases.
/// 
/// Databases need to know when the user signs out, as they should unlink the 
/// user from all the data. 
abstract class DatabaseService extends Service {
	/// Provides the database a chance to unlink all data from the user. 
	Future<void> signOut();
}
