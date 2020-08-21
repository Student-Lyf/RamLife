import "package:flutter/foundation.dart";

class Crashlytics {
	static Future<void> recordError (
		dynamic exception,
		StackTrace stack,
		{dynamic context}
	) => throw exception;

	static Future<void> recordFlutterError (
		FlutterErrorDetails details
	) => throw details.exception;

	static Future<void> setUserEmail(String email) async {}

	static void log(String message) {}
}
