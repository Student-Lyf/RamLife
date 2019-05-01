// TODO: Convert static funcs to factories
// TODO: Get Ramaz icon for login
// TODO: Retrieve user
// TODO: Verify password
// TODO: Retrieve user data 
// TODO: Retrieve day
// TODO: Retrieve period
// TODO: Handle free
// TEST: Winter fridays
// TODO: calendar

// TODO: save DB data
// VERIFY: pics across app
// TODO: verify newspaper check times

// TODOS: 
// 	Google auth -- use Ramaz email, redesign login page
// 	calendar
// 	notes
// 	sports
// 	about page (whole thing)
// 	header for next class
// 	Username validation on login
//  Use Cloud Functions + Cloud Messaging for lost and found
// 		See "lost and found.jpg"
// 	App icon
// 	"Swipe left for schedule" (shrink to fit)
// 	home page does not refresh every minute

// DB: 
// 	Students (labelled by username)
// 		Find a way to store homeroom/mincha info
// 		See backend/data/students.dart for more.
// 	classes (labelled by ID)
//  admins (labelled by username)
// 	calendar (labelled by month #)
// 	lost + found (labelled by ID)
// 	timeslots (labelled by name)

import "package:flutter/material.dart";
import "dart:async";

// Backend
import "services/reader.dart";
import "services/auth.dart" as Auth;

// UI
import "widgets/drawer.dart";
import "pages/home.dart" show HomePage;
import "pages/schedule.dart" show SchedulePage;
import "pages/login.dart" show Login;

import "constants.dart";  // for route keys

final Reader reader = Reader();
	
Future<bool> ready() async {
	await reader.init();
	return await Auth.ready() && reader.ready;
}

void main () async => runApp (
	MaterialApp (
		home: await ready() ? HomePage(reader.student) : Login(),
		title: "Student Life",
		routes: {
			HOME_PAGE: (_) => HomePage(reader.student), 
			NEWS: placeholder ("News"),
			LOST_AND_FOUND: placeholder ("Lost and found"),
			SPORTS: placeholder ("Sports"),
			ADMIN_LOGIN: placeholder ("Admin Login"),
			SCHEDULE: (_) => SchedulePage (reader.student),
			LOGIN: (_) => Login()
		}
	)
);

class PlaceholderPage extends StatelessWidget {
	final String title;
	PlaceholderPage (this.title);

	@override Widget build (BuildContext context) => Scaffold (
		drawer: NavigationDrawer(),
		appBar: AppBar (title: Text (title)),
		body: Center (child: Text ("This page is coming soon!", textScaleFactor: 2))
	);
}

Widget Function(BuildContext) placeholder(String text) => 
	(BuildContext context) => PlaceholderPage (text);