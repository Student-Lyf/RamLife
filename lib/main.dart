// BUG: Tzom should skip lunch periods
// TODO: Convert static funcs to factories
// TODO: Get Ramaz icon for login
// TODO: Retrieve user
// TODO: Verify password
// TODO: Retrieve user data 
// TODO: Retrieve day
// TODO: Retrieve period
// TODO: Handle free
// TEST: Winter fridays

import "package:flutter/material.dart";
import "drawer.dart";

import "mock.dart";

void main () => runApp (
	MaterialApp (
		home: getMainPage(),
		routes: {
			"lunch": placeholder ("lunch"),
			"schedule": placeholder ("schedule"),
			"news": placeholder ("news"),
			"lost-and-found": placeholder ("Lost and found"),
			"sports": placeholder ("sports")
		}
	)
);

class PlaceholderPage extends StatelessWidget {
	final String title;
	PlaceholderPage (this.title);

	@override Widget build (BuildContext context) => Scaffold (
		drawer: NavigationDrawer(),
		body: Expanded (
			child: Stack (
				children: [
					Placeholder(),
					Text (title)
				]
			)
		)
	);
}

Widget Function([BuildContext]) placeholder(String text) => 
	([BuildContext context]) => PlaceholderPage (text);