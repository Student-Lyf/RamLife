import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart";

class Crashlytics {
	static FirebaseCrashlytics firebase = FirebaseCrashlytics.instance;
	static Future<void> recordError (
		dynamic exception,
		StackTrace stack,
		{dynamic context}
	) => firebase.recordError(exception, stack);

	static Future<void> recordFlutterError (
		FlutterErrorDetails details
	) => firebase.recordFlutterError(details);

	static Future<void> setUserEmail(String email) => 
		firebase.setUserIdentifier(email);

	static void log(String message) => 
		firebase.log(message);
}
