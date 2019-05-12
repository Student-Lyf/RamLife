import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";

// Backend
import "services/reader.dart";
import "services/auth.dart" as Auth;
import "services/preferences.dart";
import "services/firestore.dart" as Firestore;

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

void main() async {
	final SharedPreferences prefs = await SharedPreferences.getInstance();
	final String dir = (await getApplicationDocumentsDirectory()).path;
	final Preferences preferences = Preferences(prefs);
	final Reader reader = Reader(dir);
	final bool ready = reader.ready && await Auth.ready();
	if (ready) {  // initialize data
		reader.student = Student.fromData(reader.studentData);
		reader.subjects = Subject.getSubjects(reader.subjectData);
		if (preferences.shouldUpdateCalendar) {
			final Map<String, dynamic> month = await Firestore.getMonth();
			reader.calendarData = month;
			final Map<DateTime, Day> calendar = Day.getCalendar(month);
			reader.calendar = calendar;
			preferences.lastCalendarUpdate = DateTime.now();
		}
	}
	runApp (
		MaterialApp (
			home: ready 
				? HomePage(reader)
				: Login (reader, preferences),
			title: "Student Life",
			routes: {
				LOGIN: (_) => Login(reader, preferences),
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