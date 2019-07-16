import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";

// Backend
import "services/auth.dart" as Auth;
import "services/preferences.dart";
import "services/reader.dart";
import "services/main.dart" show initOnMain;

// UI
import "widgets/theme_changer.dart" show ThemeChanger;
import "pages/splash.dart" show SplashScreen;
import "pages/drawer.dart";
import "pages/home.dart" show HomePage;
import "pages/schedule.dart" show SchedulePage;
import "pages/login.dart" show Login;
import "pages/feedback.dart" show FeedbackPage;
//import "pages/sports.dart";
 
import "constants.dart";  // for route keys
//import "mock/sports.dart" show games;

const Color BLUE = Color(0xFF004B8D);  // (255, 0, 75, 140);
const Color GOLD = Color(0xFFF9CA15);
const Color BLUE_LIGHT = Color(0XFF4A76BE);
const Color BLUE_DARK = Color (0xFF00245F);
const Color GOLD_DARK = Color (0XFFC19A00);
const Color GOLD_LIGHT = Color (0XFFFFFD56);

void main() async {
	Brightness brightness;
	runApp (
		SplashScreen(
			setBrightness: (Brightness platform) {
				brightness = platform;
			}
		)
	);
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	final String dir = (await getApplicationDocumentsDirectory()).path;
	final Preferences preferences = Preferences(prefs);
	final bool savedBrightness = preferences.brightness;
	if (savedBrightness != null) 
		brightness = savedBrightness
			? Brightness.light
			: Brightness.dark;
	final Reader reader = Reader(dir);
	// To download, and login or go to main
	final bool ready = reader.ready && await Auth.ready();
	if (ready) await initOnMain(reader, preferences);
	runApp (
		RamazApp (
			ready: ready,
			brightness: brightness,
			reader: reader, 
			prefs: preferences
		)
	);
}

class RamazApp extends StatefulWidget {
	final Brightness brightness;
	final Reader reader;
	final Preferences prefs;
	final bool ready;
	RamazApp ({
		@required this.brightness,
		@required this.reader,
		@required this.prefs,
		@required this.ready,
	});

	@override MainAppState createState() => MainAppState();
}

class MainAppState extends State<RamazApp> {
	@override 
	Widget build (BuildContext context) => ThemeChanger (
		defaultBrightness: widget.brightness,
		light: ThemeData (
			brightness: Brightness.light,
			primarySwatch: Colors.blue,
			primaryColor: BLUE,
			primaryColorBrightness: Brightness.dark,
			primaryColorLight: BLUE_LIGHT,
			primaryColorDark: BLUE_DARK,
			accentColor: GOLD,
			accentColorBrightness: Brightness.light,
			buttonColor: BLUE,
			buttonTheme: ButtonThemeData (
				buttonColor: GOLD,
				textTheme: ButtonTextTheme.normal,
			),
		),
		dark: ThemeData(
			brightness: Brightness.dark,
			scaffoldBackgroundColor: Colors.grey[850],
			primarySwatch: Colors.blue,
			primaryColorBrightness: Brightness.dark,
			primaryColorLight: BLUE_LIGHT,
			primaryColorDark: BLUE,
			accentColor: GOLD_DARK,
			accentColorBrightness: Brightness.light,
			iconTheme: IconThemeData (color: GOLD_DARK),
			primaryIconTheme: IconThemeData (color: GOLD_DARK),
			accentIconTheme: IconThemeData (color: GOLD_DARK),
			floatingActionButtonTheme: FloatingActionButtonThemeData(
				backgroundColor: GOLD_DARK,
				foregroundColor: BLUE
			),
			cardTheme: CardTheme (
				color: Colors.grey[820]
			),
			buttonColor: GOLD,
			buttonTheme: ButtonThemeData (
				buttonColor: BLUE_DARK, 
				textTheme: ButtonTextTheme.accent,
			),
		),
		builder: (BuildContext context, ThemeData theme) => MaterialApp (
			home: widget.ready
				? HomePage(reader: widget.reader, prefs: widget.prefs)
				: Login (widget.reader, widget.prefs),
			title: "Student Life",
			color: BLUE,
			theme: theme,
			routes: {
				LOGIN: (_) => Login(widget.reader, widget.prefs),
				HOME_PAGE: (_) => HomePage(reader: widget.reader, prefs: widget.prefs), 
				SCHEDULE: (_) => SchedulePage (
					reader: widget.reader, 
					prefs: widget.prefs
				),
				SCHEDULE + CAN_EXIT: (_) => SchedulePage(
					reader: widget.reader, 
					prefs: widget.prefs,
					canExit: true
				),
				NEWS: placeholder (widget.prefs, "News"),
				LOST_AND_FOUND: placeholder (widget.prefs, "Lost and found"),
				SPORTS: placeholder (widget.prefs, "Sports"),
				// SPORTS: (_) => SportsPage (games),
				ADMIN_LOGIN: placeholder (widget.prefs, "Admin Login"),
				FEEDBACK: (_) => FeedbackPage(),
			}
		)
	);
}
	
// Placeholder
class PlaceholderPage extends StatelessWidget {
	final Preferences prefs;
	final String title;
	PlaceholderPage (this.prefs, this.title);

	@override Widget build (BuildContext context) => Scaffold (
		drawer: NavigationDrawer(prefs),
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

Widget Function(BuildContext) placeholder(Preferences prefs, String text) => 
	(BuildContext context) => PlaceholderPage (prefs, text);
