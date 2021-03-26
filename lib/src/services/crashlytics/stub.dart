import "package:flutter/foundation.dart";
import "../crashlytics.dart";

/// Provides the correct implementation for web. 
Crashlytics getCrashlytics() => CrashlyticsStub();

/// Provides an empty [Crashlytics] instance. 
/// 
/// Currently, crashlytics is only available on mobile, so this implementation 
/// is used where `dart:io` is unavailable. 
class CrashlyticsStub extends Crashlytics {
	@override
	Future<void> init() async {}

	@override
	Future<void> signIn() async {}

	@override
	Future<void> recordError (
		dynamic exception,
		StackTrace stack,
		{dynamic context}
	) async => throw exception;

	@override
	Future<void> recordFlutterError (
		FlutterErrorDetails details
	) async => throw details.exception;  // ignore: only_throw_errors
	// [FlutterErrorDetails.exception] is an [Object], and can be any value. 

	@override
	Future<void> setEmail(String email) async {}

	@override
	Future<void> log(String message) async {}

	@override
	Future<void> toggle(bool value) async {}
}
