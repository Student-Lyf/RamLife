import "package:firebase_crashlytics/firebase_crashlytics.dart" show FirebaseCrashlytics;
import "package:flutter/foundation.dart";

import "../crashlytics.dart";
import "../firebase_core.dart";

Crashlytics getCrashlytics() => CrashlyticsImplementation();

class CrashlyticsImplementation extends Crashlytics {
	static FirebaseCrashlytics firebase = FirebaseCrashlytics.instance;

	@override
	Future<void> init() async {
		await FirebaseCore.init();
		didCrashLastTime = await firebase.didCrashOnPreviousExecution();
		if (didCrashLastTime) {
			await log("App crashed on last run");
		}
	}

	@override
	Future<void> signIn() async {}

	@override
	Future<void> recordError (
		dynamic exception,
		StackTrace stack,
		{dynamic context}
	) => firebase.recordError(exception, stack);

	@override
	Future<void> recordFlutterError (
		FlutterErrorDetails details
	) => firebase.recordFlutterError(details);

	@override
	Future<void> setEmail(String email) => 
		firebase.setUserIdentifier(email);

	@override
	Future<void> log(String message) => 
		firebase.log(message);

	// ignore: avoid_positional_boolean_parameters
	@override
	Future<void> toggle(bool value) => 
		firebase.setCrashlyticsCollectionEnabled(value);
}
