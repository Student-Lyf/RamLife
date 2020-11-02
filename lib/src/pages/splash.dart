// ignore_for_file: prefer_const_constructors_in_immutables
import "dart:async";

import "package:flutter/material.dart"; 
import "package:flutter/foundation.dart" show kDebugMode;
import "package:flutter/services.dart";

import "package:ramaz/app.dart";
import "package:ramaz/models.dart";
import "package:ramaz/services.dart";
import "package:ramaz/widgets.dart";

/// A splash screen that discreetly loads the device's brightness. 
class SplashScreen extends StatefulWidget {
	@override
	SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
	bool firstTry = true;
	bool hasError = false;

	Brightness brightness;
	bool isSignedIn;
	bool isLoading = false;
	String error;

	@override
	void initState() {
		super.initState();
		SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
		init();
	}

	Future<void> init() async {
		await initServices();
		initBrightness();
		if (isSignedIn) {
			try {
				await Models.instance.init();
			} catch (code, stack) {  // ignore: avoid_catches_without_on_clauses
				debugPrint("[SplashScreenState.init]: Error loading data");
				if (!firstTry && !kDebugMode) {
					debugPrint("  Wiping data and trying again");
					await Services.instance.database.signOut();
					firstTry = false;
					return init();
				} else {
					setState(() {
						isLoading = false;
						hasError = true;
						error = "$code\n$stack";
					});
					rethrow;
				}
			}
		}
		await launchApp();
	}

	void initBrightness() {
		final bool isLightMode = Services.instance.prefs.brightness;
		final Brightness brightness = isLightMode == null
			? MediaQuery.of(context).platformBrightness
			: isLightMode ? Brightness.light : Brightness.dark;
		ThemeChanger.of(context).brightness = brightness;
	}

	Future<void> initServices() async {
		// This initializes services -- it is always safe. 
		await Services.instance.init();
		isSignedIn = Services.instance.database.isSignedIn;
	}

	Future<void> launchApp() async {
		final Crashlytics crashlytics = Services.instance.crashlytics;
		await crashlytics.toggle(!kDebugMode);
		FlutterError.onError = crashlytics.recordFlutterError;
		runZonedGuarded(
			() => runApp(RamLife(isSignedIn: isSignedIn)),
			crashlytics.recordError,
		);
	}

	@override 
	Widget build (BuildContext context) => Scaffold(
		body: !hasError 
			? const Center(child: RamazLogos.ramSquareWords)
			: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20),
				child: Column(
					children: [
						if (isLoading)
							const LinearProgressIndicator(),
						const Spacer(flex: 5),
						Text(
							"RamLife is having difficulties starting. Make sure your app " 
							"is updated and try again.",
							style: Theme.of(context).textTheme.headline4,
							textAlign: TextAlign.center,
						),
						const Spacer(flex: 2),
						OutlineButton(
							onPressed: () async {
								setState(() => isLoading = true);
								await Services.instance.database.signOut();
								await init();
							},
							child: const Text("Reset"),
						),
						const Spacer(flex: 1),
						Text(
							"The exact error is below",
							style: Theme.of(context).textTheme.subtitle1,
						),
						const SizedBox(height: 30),
						SizedBox(
							height: 200, 
							child: SingleChildScrollView(
								child: Text(
									error,
									style: Theme.of(context).textTheme.caption.copyWith(
										color: Theme.of(context).colorScheme.error,
									),
								),
							),
						),
						const Spacer(flex: 3),
					]
				)	
			)
	);
}