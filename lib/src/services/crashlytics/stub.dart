import "package:flutter/foundation.dart";
import "../crashlytics.dart";

Crashlytics getCrashlytics() => CrashlyticsStub();

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
	) async => throw details.exception;

	@override
	Future<void> setEmail(String email) async {}

	@override
	Future<void> log(String message) async {}

	@override
	Future<void> toggle(bool value) async {}
}
