import "package:firebase_crashlytics/firebase_crashlytics.dart" show FirebaseCrashlytics;
import "package:flutter/foundation.dart";

import "../crashlytics.dart";
import "../firebase_core.dart";

/// Provides the correct implementation for mobile. 
Crashlytics getCrashlytics() => CrashlyticsImplementation();

/// Connects the app to Firebase Crashlytics. 
/// 
/// Currently, Crashlytics is only available on mobile, so this implementation
/// is only used where `dart:io` is available. 
class CrashlyticsImplementation extends Crashlytics {
	/// Provides the connection to Firebase Crashlytics. 
	static FirebaseCrashlytics firebase = FirebaseCrashlytics.instance;

	@override
	Future<void> init() async {
		await FirebaseCore.init();
		final bool didCrashLastTime = await firebase.didCrashOnPreviousExecution();
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

	@override
	Future<void> toggle(bool value) => 
		firebase.setCrashlyticsCollectionEnabled(value);
}
