// ignore_for_file: prefer_const_constructors_in_immutables
import "dart:async";

import "package:flutter/material.dart"; 
import "package:flutter/foundation.dart" show kDebugMode;
import "package:flutter/services.dart";

import "package:ramaz/services.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";
import "package:ramaz/main.dart";

/// A splash screen that discreetly loads the device's brightness. 
class SplashScreen extends StatefulWidget {
	@override
	SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
	Brightness brightness;
	bool isSignedIn;
	bool firstTry = true;

	@override
	void initState() {
		super.initState();
		SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
		init();
	}

	Future<void> init() async {
		await initServices();
		if (isSignedIn) {
			try {
				await Models.instance.init();
			} catch(error) {  // ignore: avoid_catches_without_on_clauses
				debugPrint("[SplashScreenState.init]: Error loading data");
				if (!firstTry && !kDebugMode) {
					debugPrint("  Wiping data and trying again");
					await Services.instance.database.signOut();
					firstTry = false;
					return init();
				} else {
					// TODO: open error page. 
				}
			}
		}
		await launchApp();
	}

	Future<void> initServices() async {
		// This initializes services -- it is always safe. 
		await Services.instance.init();
		isSignedIn = Services.instance.database.isSignedIn;
	}

	Future<void> launchApp() async {
		final bool isLightMode = Services.instance.prefs.brightness;
		final Brightness brightness = isLightMode == null
			? MediaQuery.of(context).platformBrightness
			: isLightMode ? Brightness.light : Brightness.dark;
		final Crashlytics crashlytics = Services.instance.crashlytics;
		await crashlytics.toggle(!kDebugMode);
		FlutterError.onError = crashlytics.recordFlutterError;
		ThemeChanger.of(context).brightness = brightness;
		runZonedGuarded(
			() => runApp(
				RamazApp(
					isSignedIn: isSignedIn,
				)
			),
			crashlytics.recordError,
		);
	}

	@override 
	Widget build (BuildContext context) => const Scaffold(
		body: Center(child: RamazLogos.ramSquareWords)
	);
}