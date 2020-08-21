import "package:firebase_crashlytics/firebase_crashlytics.dart" as fb;
import "package:flutter/foundation.dart";

class Crashlytics {
	static Future<void> recordError (
		dynamic exception,
		StackTrace stack,
		{dynamic context}
	) => fb.Crashlytics.instance.recordError(exception, stack, context: context);

	static Future<void> recordFlutterError (
		FlutterErrorDetails details
	) => fb.Crashlytics.instance.recordFlutterError(details);

	static Future<void> setUserEmail(String email) => 
		fb.Crashlytics.instance.setUserEmail(email);

	static void log(String message) => 
		fb.Crashlytics.instance.log(message);
}
