import "package:flutter/foundation.dart";

import "crashlytics/stub.dart"
	if (dart.library.io) "crashlytics/mobile.dart";

import "service.dart";

/// A wrapper around the Crashlytics SDK.
/// 
/// Crashlytics is a service that helps report errors from apps already in use.
/// Crashes and errors can be found in the Firebase console. 
/// 
/// This class has a singleton, since there are multiple implementations. Use
/// [Crashlytics.instance]. 
abstract class Crashlytics extends Service {
	/// The singleton of this object. 
	static Crashlytics instance = getCrashlytics();

	/// Whether the app crashed last time it ran. 
	/// 
	/// A "crash" according to Firebase is a fatal-error at the native level. So 
	/// most Flutter errors should not trigger this. In the future, however, it 
	/// may be helpful. 
	bool didCrashLastTime = false;

	/// Records an error to Crashlytics. 
	/// 
	/// This function is meant for Dart errors. For Flutter errors, use 
	/// [recordFlutterError]. 
	Future<void> recordError(
		dynamic exception,
		StackTrace stack,
		{dynamic context}
	);

	/// Records an error in the Flutter framework. 
	Future<void> recordFlutterError(FlutterErrorDetails details);

	/// Sets the email of the current user. 
	/// 
	/// This is helpful when looking through error reports, and enables us to dig 
	/// around the database and find corrupted data. 
	Future<void> setEmail(String email);

	/// Logs a message to Crashlytics. 
	/// 
	/// Put these everywhere. That way, if the app does crash, the error report
	/// will be full of context. 
	Future<void> log(String message);

	/// Toggles Crashlytics on or off. 
	/// 
	/// This should always be set to on (and it is by default), except for when 
	/// the app is running in dev mode. 
	// ignore: avoid_positional_boolean_parameters
	Future<void> toggle(bool value);
}
