import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";

/// A wrapper around [Firebase].
/// 
/// Firebase needs to be initialized before any Firebase products can be used.
/// However, it is an error to initialize Firebase more than once. To simplify 
/// the process, we register Firebase as a separate service that can keep track
/// of whether it has been initialized. 
class FirebaseCore {
	/// Whether the Firebase Local Emulator Suite should be used. 
	///
	/// This setting should be enabled during development ONLY. We can also use 
	/// `kDebugMode` from `flutter/foundation`, but it's also valid to test UI 
	/// or logic operations with the production database.
	static bool shouldUseEmulator = false;
	
	/// Whether Firebase has already been initialized.
	static bool initialized = false;

	/// Initializes Firebase if it hasn't already been. 
	static Future<void> init() async {
		// if (!initialized) {
		// 	await Firebase.initializeApp();
		// 	if(shouldUseEmulator){
		// 		await FirebaseAuth.instance.useAuthEmulator("localhost",9099);
		// 	}
		// 	initialized = true;
		// }
	}
}