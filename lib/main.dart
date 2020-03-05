import "dart:async" show runZoned;

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:ramaz/constants.dart";  // for route keys
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
import "package:ramaz/services_collection.dart";
import "package:ramaz/widgets.dart";

Future<void> main({bool restart = false}) async {
	// This shows a splash screen but secretly 
	// determines the desired `platformBrightness`
	Brightness brightness;
	runZoned(
		() => runApp (
			SplashScreen(
				setBrightness: 
					(Brightness platform) => brightness = platform
			)
		),
		onError: Crashlytics.instance.recordError,
	);
	await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

	// Initialize basic backend
	// 
	// First, get the raw materials. 
	// 	This is done here since they are `Future`s, and this is
	// 	the only place those `Future`s can be reliably `await`ed. 
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	final String dir = (await getApplicationDocumentsDirectory()).path;

	ServicesCollection services;
	Reader reader;
	bool ready;
	try {
		// Now, actually initialize the backend services.

		// Reader is kept out of ServicesCollection so it can be used to reset
		reader = Reader(dir);
		services = ServicesCollection(
			reader: reader,
			prefs: Preferences(prefs),
		);
		
		// To download, and login or go to main
		ready = services.reader.ready && await Auth.ready;
		if (ready) {
			await services.init();
		}
	// We want to at least try again on ANY error. 
	// ignore: avoid_catches_without_on_clauses
	} catch (_) {
		debugPrint ("Error on main.");
		if (!restart) {
			debugPrint ("Trying again...");
			await Auth.signOut();
			reader.deleteAll();
			return main(restart: true);
		} else {
			rethrow;
		}
	}

	// Determine the appropriate brightness. 
	final bool savedBrightness = services.prefs.brightness;
	if (savedBrightness != null) {
		brightness = savedBrightness
			? Brightness.light
			: Brightness.dark;
	}

	// Now we are ready to run the app (with error catching)
	FlutterError.onError = Crashlytics.instance.recordFlutterError;
	runZoned(
		() => runApp (
			RamazApp (
				ready: ready,
				brightness: brightness,
				services: services,
			)
		),
		onError: Crashlytics.instance.recordError,
	);
}

/// The main app widget. 
class RamazApp extends StatelessWidget {
	/// The brightness to default to. 
	final Brightness brightness;

	/// The services to use. 
	final ServicesCollection services;

	/// Whether the user is ready to go straight to the app or must first log int. 
	final bool ready;

	/// Creates the main app widget.
	const RamazApp ({
		@required this.brightness,
		@required this.ready,
		@required this.services,
	});

	@override 
	Widget build (BuildContext context) => Services (
		services: services,
		child: ThemeChanger (
			defaultBrightness: brightness,
			light: ThemeData (
				brightness: Brightness.light,
				primarySwatch: Colors.blue,
				primaryColor: RamazColors.blue,
				primaryColorBrightness: Brightness.dark,
				primaryColorLight: RamazColors.blueLight,
				primaryColorDark: RamazColors.blueDark,
				accentColor: RamazColors.gold,
				accentColorBrightness: Brightness.light,
				cursorColor: RamazColors.blueLight,
				textSelectionHandleColor: RamazColors.blueLight,
				buttonColor: RamazColors.gold,
				buttonTheme: ButtonThemeData (
					buttonColor: RamazColors.gold,
					textTheme: ButtonTextTheme.normal,
				),
			),
			dark: ThemeData(
				brightness: Brightness.dark,
				scaffoldBackgroundColor: Colors.grey[850],
				primarySwatch: Colors.blue,
				primaryColorBrightness: Brightness.dark,
				primaryColorLight: RamazColors.blueLight,
				primaryColorDark: RamazColors.blueDark,
				accentColor: RamazColors.goldDark,
				accentColorBrightness: Brightness.light,
				iconTheme: IconThemeData (color: RamazColors.goldDark),
				primaryIconTheme: IconThemeData (color: RamazColors.goldDark),
				accentIconTheme: IconThemeData (color: RamazColors.goldDark),
				floatingActionButtonTheme: FloatingActionButtonThemeData(
					backgroundColor: RamazColors.goldDark,
					foregroundColor: RamazColors.blue
				),
				cursorColor: RamazColors.blueLight,
				textSelectionHandleColor: RamazColors.blueLight,
				cardTheme: CardTheme (
					color: Colors.grey[820]
				),
				toggleableActiveColor: RamazColors.blueLight,
				buttonColor: RamazColors.blueDark,
				buttonTheme: ButtonThemeData (
					buttonColor: RamazColors.blueDark, 
					textTheme: ButtonTextTheme.accent,
				),
			),
			builder: (BuildContext context, ThemeData theme) => MaterialApp (
				home: ready
					? HomePage()
					: Login(services),
				title: "Student Life",
				color: RamazColors.blue,
				theme: theme,
				routes: {
					Routes.login: (_) => Login(services),
					Routes.home: (_) => HomePage(),
					Routes.schedule: (_) => SchedulePage(),
					Routes.reminders: (_) => RemindersPage(),
					Routes.feedback: (_) => FeedbackPage(),
					Routes.calendar: (_) => CalendarPage(),
					Routes.specials: (_) => SpecialPage(),
					Routes.admin: (_) => AdminHomePage(),
					Routes.sports: (_) => SportsPage(),
				}
			)
		)
	);
}
