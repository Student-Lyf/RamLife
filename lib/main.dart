import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";

// Backend
import "services/auth.dart" as Auth;
import "services/preferences.dart";
import "services/reader.dart";
import "services/main.dart" show initOnMain;

// UI
import "widgets/brightness.dart" show BrightnessChanger;
import "pages/splash.dart" show SplashScreen;
import "pages/drawer.dart";
import "pages/home.dart" show HomePage;
import "pages/schedule.dart" show SchedulePage;
import "pages/login.dart" show Login;
import "pages/feedback.dart" show FeedbackPage;
// import "pages/sports.dart";

import "constants.dart";  // for route keys
// import "mock/sports.dart" show games;

const Color BLUE = Color(0xFF004B8D);  // (255, 0, 75, 140);
const Color GOLD = Color(0xFFF9CA15);
const Color BLUE_LIGHT = Color(0XFF4A76BE);
const Color BLUE_DARK = Color (0xFF00245F);
const Color GOLD_DARK = Color (0XFFC19A00);
const Color GOLD_LIGHT = Color (0XFFFFFD56);

const Color DARK_MODE_GOLD = Color (0xFF333300);
const Color DARK_MODE_BLUE = Color (0XFF000033);

void main() async {
	Brightness brightness;
	runApp (
		SplashScreen(
			setBrightness: (Brightness platform) => brightness = platform
		)
	);
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	final String dir = (await getApplicationDocumentsDirectory()).path;
	final Preferences preferences = Preferences(prefs);
	final Reader reader = Reader(dir);
	// reader.deleteAll();
	final bool ready = reader.ready && await Auth.ready();
	if (ready) await initOnMain(reader, preferences);
	runApp (RamazApp (ready, reader, preferences));
}

class RamazApp extends StatelessWidget {
	final bool ready;
	final Reader reader;
	final Preferences prefs;
	RamazApp (this.ready, this.reader, this.prefs);

	@override 
	Widget build (BuildContext context) => BrightnessChanger (
		light: ThemeData (  // light
			brightness: Brightness.light,
			primarySwatch: Colors.blue,
			primaryColor: BLUE,
			primaryColorBrightness: Brightness.dark,
			primaryColorLight: BLUE_LIGHT,
			primaryColorDark: BLUE_DARK,
			accentColor: GOLD,
			accentColorBrightness: Brightness.light,
			// cardColor: GOLD,
			buttonColor: BLUE,
			buttonTheme: ButtonThemeData (
				buttonColor: GOLD,
				textTheme: ButtonTextTheme.accent
			),
		),
		dark: ThemeData(  // dark
			brightness: Brightness.dark,
			scaffoldBackgroundColor: Colors.grey[700],
			primarySwatch: Colors.blue,
			// primaryColor: DARK_MODE_BLUE,
			primaryColorBrightness: Brightness.dark,
			primaryColorLight: BLUE_LIGHT,
			primaryColorDark: BLUE,
			accentColor: GOLD_DARK,
			accentColorBrightness: Brightness.light,
			textTheme: Typography.whiteMountainView.apply(
				bodyColor: BLUE_LIGHT,
				displayColor: GOLD_DARK
			),
			iconTheme: IconThemeData (color: GOLD),
			primaryIconTheme: IconThemeData (color: GOLD_DARK),
			accentIconTheme: IconThemeData (color: GOLD_DARK),
			floatingActionButtonTheme: FloatingActionButtonThemeData(
				backgroundColor: GOLD_DARK,
				foregroundColor: BLUE
			)
		),
		builder: (BuildContext context, ThemeData theme) => MaterialApp (
			home: ready 
				? HomePage(reader)
				: Login (reader, prefs),
			title: "Student Life",
			color: BLUE,
			theme: theme,
			routes: {
				LOGIN: (_) => Login(reader, prefs),
				HOME_PAGE: (_) => HomePage(reader), 
				SCHEDULE: (_) => SchedulePage (reader),
				SCHEDULE + CAN_EXIT: (_) => SchedulePage(reader, canExit: true),
				NEWS: placeholder ("News"),
				LOST_AND_FOUND: placeholder ("Lost and found"),
				SPORTS: placeholder ("Sports"),
				// SPORTS: (_) => SportsPage (games),
				ADMIN_LOGIN: placeholder ("Admin Login"),
				FEEDBACK: (_) => FeedbackPage(),
			} 
		)
	);
}
	
// Placeholder
class PlaceholderPage extends StatelessWidget {
	final String title;
	PlaceholderPage (this.title);

	@override Widget build (BuildContext context) => Scaffold (
		drawer: NavigationDrawer(),
		appBar: AppBar (
			title: Text (title),
			actions: [
				IconButton (
					icon: Icon (Icons.home),
					onPressed: () => Navigator.of(context).pushReplacementNamed(HOME_PAGE)
				)
			]
		),
		body: Center (child: Text ("This page is coming soon!", textScaleFactor: 2))
	);
}

Widget Function(BuildContext) placeholder(String text) => 
	(BuildContext context) => PlaceholderPage (text);
