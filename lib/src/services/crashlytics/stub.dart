import "package:flutter/foundation.dart";

class Crashlytics {
	static dynamic firebase;

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

	// ignore: avoid_positional_boolean_parameters
	static Future<void> toggle(bool value) async {}
}
