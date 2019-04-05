// Verify: Light blue color
// TODO: add border radius for InfoCard

import "package:flutter/material.dart";
import "drawer.dart";
import "footer.dart";

class InfoCard extends StatelessWidget {
	final String text;
	const InfoCard (this.text);

	@override Widget build (BuildContext context) => Card (
		color: Colors.lightBlueAccent,
		child: Text (text, style: TextStyle (color: Colors.white)),
	);
}

class HomePage extends StatelessWidget {
	@override Widget build (BuildContext context) => Scaffold (
		drawer: NavigationDrawer(),
		bottomNavigationBar: Footer(),
		body: Column (
			mainAxisSize: MainAxisSize.min, 
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				InfoCard("This is the class you have now"),
				InfoCard("This is today's lunch"),
				InfoCard("These are today's sports games")
			]
		)
	);
}