import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";


import "package:ramaz/constants.dart";  // for route keys
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
import "package:ramaz/services_collection.dart";
import "package:ramaz/widgets.dart";

/// Completely refresh the user's schedule 
/// Basically simulate the login sequence
Future<void> refresh(ServicesCollection services) async {
	final String email = await Auth.getEmail();
	if (email == null) throw StateError(
		"Cannot refresh schedule because the user is not logged in."
	);
	await services.initOnLogin(email, false);
	services.notes.setup();
	services.schedule.setup(services.reader);
}

void main({bool restart = false}) async {
	// This shows a splash screen but secretly 
	// determines the desired `platformBrightness`
	Brightness brightness;
	runApp (
		SplashScreen(
			setBrightness: 
				(Brightness platform) => brightness = platform
		)
	);

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
		ready = services.reader.ready && await Auth.ready();
		if (ready) await services.initOnMain();
	} catch (error) {
		print ("Error on main.");
		if (!restart) {
			print ("Trying again...");
			await Auth.signOut();
			reader.deleteAll();
			main(restart: true);
		} else rethrow;
	}

	// Determine the appropriate brightness. 
	final bool savedBrightness = services.prefs.brightness;
	if (savedBrightness != null) brightness = savedBrightness
		? Brightness.light
		: Brightness.dark;

	// Register for FCM notifications. 
	Future(
		() async {
			await FCM.registerNotifications(
				{
					"refresh": () async => await refresh(services)
				}
			);
			print ("Device notification id: ${await FCM.getToken()}");
		}
	);

	// Now we are ready to run the app
	runApp (
		RamazApp (
			ready: ready,
			brightness: brightness,
			services: services,
		)
	);
}

class RamazApp extends StatefulWidget {
	final Brightness brightness;
	final ServicesCollection services;
	final bool ready;
	RamazApp ({
		@required this.brightness,
		@required this.ready,
		@required this.services,
	});

	@override MainAppState createState() => MainAppState();
}

class MainAppState extends State<RamazApp> {
	@override 
	Widget build (BuildContext context) => Services (
		services: widget.services,
		child: ThemeChanger (
			defaultBrightness: widget.brightness,
			light: ThemeData (
				brightness: Brightness.light,
				primarySwatch: Colors.blue,
				primaryColor: RamazColors.BLUE,
				primaryColorBrightness: Brightness.dark,
				primaryColorLight: RamazColors.BLUE_LIGHT,
				primaryColorDark: RamazColors.BLUE_DARK,
				accentColor: RamazColors.GOLD,
				accentColorBrightness: Brightness.light,
				cursorColor: RamazColors.BLUE_LIGHT,
				textSelectionHandleColor: RamazColors.BLUE_LIGHT,
				buttonColor: RamazColors.GOLD,
				buttonTheme: ButtonThemeData (
					buttonColor: RamazColors.GOLD,
					textTheme: ButtonTextTheme.normal,
				),
			),
			dark: ThemeData(
				brightness: Brightness.dark,
				scaffoldBackgroundColor: Colors.grey[850],
				primarySwatch: Colors.blue,
				primaryColorBrightness: Brightness.dark,
				primaryColorLight: RamazColors.BLUE_LIGHT,
				// primaryColor: RamazColors.BLUE,
				primaryColorDark: RamazColors.BLUE_DARK,
				accentColor: RamazColors.GOLD_DARK,
				accentColorBrightness: Brightness.light,
				iconTheme: IconThemeData (color: RamazColors.GOLD_DARK),
				primaryIconTheme: IconThemeData (color: RamazColors.GOLD_DARK),
				accentIconTheme: IconThemeData (color: RamazColors.GOLD_DARK),
				floatingActionButtonTheme: FloatingActionButtonThemeData(
					backgroundColor: RamazColors.GOLD_DARK,
					foregroundColor: RamazColors.BLUE
				),
				cursorColor: RamazColors.BLUE_LIGHT,
				textSelectionHandleColor: RamazColors.BLUE_LIGHT,
				cardTheme: CardTheme (
					color: Colors.grey[820]
				),
				toggleableActiveColor: RamazColors.BLUE_LIGHT,
				buttonColor: RamazColors.BLUE_DARK,
				buttonTheme: ButtonThemeData (
					buttonColor: RamazColors.BLUE_DARK, 
					textTheme: ButtonTextTheme.accent,
				),
			),
			builder: (BuildContext context, ThemeData theme) => MaterialApp (
				home: widget.ready
					? HomePage()
					: Login(),
				title: "Student Life",
				color: RamazColors.BLUE,
				theme: theme,
				routes: {
					Routes.LOGIN: (_) => Login(),
					Routes.HOME: (_) => HomePage(),
					Routes.SCHEDULE: (_) => SchedulePage(),
					Routes.NOTES: (_) => NotesPage(),
					// Routes.NEWS: placeholder ("News"),
					// Routes.LOST_AND_FOUND: placeholder ("Lost and found"),
					// Routes.SPORTS: placeholder ("Sports"),
					// Routes.SPORTS: (_) => SportsPage (games),
					// Routes.ADMIN_LOGIN: placeholder ("Admin Login"),
					Routes.FEEDBACK: (_) => FeedbackPage(),
				}
			)
		)
	);
}
	
// Placeholder
// class PlaceholderPage extends StatelessWidget {
// 	final String title;
// 	PlaceholderPage (this.title);

// 	@override Widget build (BuildContext context) => Scaffold (
// 		drawer: NavigationDrawer(),
// 		appBar: AppBar (
// 			title: Text (title),
// 			actions: [
// 				IconButton (
// 					icon: Icon (Icons.home),
// 					onPressed: () => Navigator.of(context).pushReplacementNamed(HOME_PAGE)
// 				)
// 			]
// 		),
// 		body: Center (child: Text ("This page is coming soon!", textScaleFactor: 2))
// 	);
// }

// Widget Function(BuildContext) placeholder(String text) => 
// 	(BuildContext context) => PlaceholderPage (text);
