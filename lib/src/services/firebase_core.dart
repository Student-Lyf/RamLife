import "package:firebase_core/firebase_core.dart";

class FirebaseCore {
	static bool initialized = false;

	static Future<void> init() async {
		if (!initialized) {
			await Firebase.initializeApp();
			initialized = true;
		}
	}
}