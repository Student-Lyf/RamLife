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

// TODOS: 
// 	Google auth -- use Ramaz email, redesign login page
// 	calendar
// 	notes
// 	sports
// 	new logo (drawer, header, login)
// 	lost + found chat/threads
// 	about page (whole thing)
// 	header for next class

// DB: 
// 	Students (labelled by username)
// 	classes (labelled by ID)
//  admins (labelled by username)
// 	calendar (labelled by month #)
// 	lost + found (labelled by ID)
// 	timeslots (labelled by name)



import "package:flutter/material.dart";

// used to mock all other pages
import "widgets/drawer.dart";
import "mock.dart" show levi;

import "constants.dart";  // for route keys
import "widgets/home.dart" show HomePage;
import "widgets/schedule.dart" show SchedulePage;
import "widgets/login.dart" show Login;

void main () => runApp (
	MaterialApp (
		home: HomePage(levi),
		title: "Student Life",
		routes: {
			HOME_PAGE: (_) => HomePage(levi), 
			NEWS: placeholder ("News"),
			LOST_AND_FOUND: placeholder ("Lost and found"),
			SPORTS: placeholder ("Sports"),
			ADMIN_LOGIN: placeholder ("Admin Login"),
			SCHEDULE: (_) => SchedulePage (levi),
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