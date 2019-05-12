import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";

// Backend
import "services/reader.dart";
import "services/auth.dart" as Auth;

// Dataclasses
import "data/student.dart";
import "data/schedule.dart";

// UI
import "widgets/brightness.dart" show BrightnessChanger;
import "pages/drawer.dart";
import "pages/home.dart" show HomePage;
import "pages/schedule.dart" show SchedulePage;
import "pages/login.dart" show Login;
import "pages/feedback.dart" show FeedbackPage;
import "pages/sports.dart";

import "constants.dart";  // for route keys
import "mock/sports.dart" show games;

const Color BLUE = Color(0xFF004B8D);  // (255, 0, 75, 140);
const Color GOLD = Color(0xFFF9CA15);
const Color BLUE_LIGHT = Color(0XFF4A76BE);
const Color BLUE_DARK = Color (0xFF00245F);
const Color GOLD_DARK = Color (0XFFC19A00);
const Color GOLD_LIGHT = Color (0XFFFFFD56);

const Color DARK_MODE_GOLD = Color (0xFF333300);
const Color DARK_MODE_BLUE = Color (0XFF4AB8ED);

void main() async {
	final String dir = (await getApplicationDocumentsDirectory()).path;
	final Reader reader = Reader(dir);
	final bool ready = reader.ready && await Auth.ready();
	if (ready) {
		reader.student = Student.fromData(reader.studentData);
		reader.subjects = Subject.getSubjects(reader.subjectData);
	}
	runApp (RamazApp(ready, reader));
}

class RamazApp extends StatelessWidget {
	final bool ready;
	final Reader reader;
	RamazApp(this.ready, this.reader);
	@override 
	Widget build (BuildContext context) => BrightnessChanger (
		builder: (BuildContext context, Brightness brightness) => MaterialApp (
			home: ready 
				? HomePage(reader)
				: Login (reader),
			title: "Student Life",
			color: BLUE,
			theme: brightness == Brightness.light 
				? ThemeData (
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
				)
			: ThemeData(
				brightness: Brightness.dark,
				scaffoldBackgroundColor: Colors.grey[700],
				primarySwatch: Colors.blue,
				primaryColor: const Color (0xFF00245F),
				primaryColorBrightness: Brightness.dark,
				primaryColorLight: const Color(0XFF4A76BE),
				primaryColorDark: BLUE,
				accentColor: GOLD,
				accentColorBrightness: Brightness.light,
				textTheme: Typography.whiteMountainView.apply(
					bodyColor: GOLD,
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
			routes: {
				LOGIN: (_) => Login(reader),
				HOME_PAGE: (_) => HomePage(reader), 
				SCHEDULE: (_) => SchedulePage (reader),
				SCHEDULE + CAN_EXIT: (_) => SchedulePage(reader, canExit: true),
				NEWS: placeholder ("News"),
				LOST_AND_FOUND: placeholder ("Lost and found"),
				SPORTS: placeholder ("Sports"),
				SPORTS: (_) => SportsPage (games),
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