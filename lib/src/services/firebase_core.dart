import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";

import "package:ramaz/firebase_options.dart";

/// A wrapper around [Firebase].
/// 
/// Firebase needs to be initialized before any Firebase products can be used.
/// However, it is an error to initialize Firebase more than once. To simplify 
/// the process, we register Firebase as a separate service that can keep track
/// of whether it has been initialized. 
class FirebaseCore {
	/// Whether the Firebase Local Emulator Suite should be used. 
	static bool shouldUseEmulator = kDebugMode;
	
	/// Whether Firebase has already been initialized.
	static bool initialized = false;

	/// Initializes Firebase as configured by flutterfire_cli
	static Future<void> init() async {
		await Firebase.initializeApp(
		  options: DefaultFirebaseOptions.currentPlatform,
		);
		if (shouldUseEmulator) {
			await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
			// Setting the emulator after a hot restart breaks Firestore. 
			// See: https://github.com/FirebaseExtended/flutterfire/issues/6216
			try { FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080); }
			catch (error) {  // throws a JavaScript object instead of a FirebaseException
				final String code = (error as dynamic).code;
				if (code != "failed-precondition") {
					rethrow; 
				}
			}
		}
	}
}