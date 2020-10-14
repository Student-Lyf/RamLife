import "package:flutter/foundation.dart";

import "crashlytics/stub.dart"
	if (dart.library.io) "crashlytics/mobile.dart";

import "service.dart";

abstract class Crashlytics extends Service {
	static Crashlytics instance = getCrashlytics();

	bool didCrashLastTime = false;

	Future<void> recordError(
		dynamic exception,
		StackTrace stack,
		{dynamic context}
	);

	Future<void> recordFlutterError(FlutterErrorDetails details);

	Future<void> setEmail(String email);

	Future<void> log(String message);

	// ignore: avoid_positional_boolean_parameters
	Future<void> toggle(bool value);
}