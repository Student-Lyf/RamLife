import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";

// Backend
import "services/reader.dart";
import "services/auth.dart" as Auth;

// Dataclasses
import "data/student.dart";
import "data/schedule.dart";

// UI
import "pages/drawer.dart";
import "pages/home.dart" show HomePage;
import "pages/schedule.dart" show SchedulePage;
import "pages/login.dart" show Login;
import "pages/feedback.dart" show FeedbackPage;
// import "pages/sports.dart";

import "constants.dart";  // for route keys
// import "mock/sports.dart" show games;

const Color RAMAZ_BLUE = Color(0xFF004B8D);  // (255, 0, 75, 140);

void main() async {
	final String dir = (await getApplicationDocumentsDirectory()).path;
	final Reader reader = Reader(dir);
	final bool ready = reader.ready && await Auth.ready();
	if (ready) {
		reader.student = Student.fromData(reader.studentData);
		reader.subjects = Subject.getSubjects(reader.subjectData);
	}
	runApp (
		RamazApp(ready, reader)
	);
	// 	MaterialApp (
	// 		home: ready 
	// 			? HomePage(reader)
	// 			: Login (reader),
	// 		title: "Student Life",
	// 		color: RAMAZ_BLUE,
	// 		theme: theme,
	// 		// darkTheme: null,
	// 		routes: {
	// 			LOGIN: (_) => Login(reader),
	// 			HOME_PAGE: (_) => HomePage(reader), 
	// 			SCHEDULE: (_) => SchedulePage (reader),
	// 			SCHEDULE + CAN_EXIT: (_) => SchedulePage(reader, canExit: true),
	// 			NEWS: placeholder ("News"),
	// 			LOST_AND_FOUND: placeholder ("Lost and found"),
	// 			SPORTS: placeholder ("Sports"),
	// 			// SPORTS: (_) => SportsPage (games),
	// 			ADMIN_LOGIN: placeholder ("Admin Login"),
	// 			FEEDBACK: (_) => FeedbackPage(),
	// 		} 
	// 	)
	// );
}

class RamazApp extends StatelessWidget {
	final bool ready;
	final Reader reader;
	RamazApp(this.ready, this.reader);
	@override 
	Widget build (BuildContext context) => MaterialApp (
		home: ready 
			? HomePage(reader)
			: Login (reader),
		title: "Student Life",
		color: RAMAZ_BLUE,
		theme: ThemeData (
			brightness: Brightness.light,
			primarySwatch: Colors.blue,
			primaryColor: RAMAZ_BLUE,
			primaryColorBrightness: Brightness.dark,
			primaryColorLight: const Color(0XFF4A76BE),
			primaryColorDark: const Color (0xFF00245F),
			accentColor: const Color (0XFFF9CA15),
			accentColorBrightness: Brightness.light,
		),
		// darkTheme: null,
		routes: {
			LOGIN: (_) => Login(reader),
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