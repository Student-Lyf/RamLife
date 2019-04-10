// TODO: open links: 
	// - ramaz.org
	// - mymail.ramaz.org
	// - app.schoology.com
	// - myBackPack

// calendar, notes, schedule
// new icon (drawer, header)
// lost + found chat
// about page (whole thing)
// header for next class


import "package:flutter/material.dart";

const String SCHOOLOGY = "app.schoology.com";
const String EMAIL = "mymail.ramaz.org";
const String RAMAZ = "ramaz.org";
const String BACKPACK = "";  // TODO 

class NavigationDrawer extends StatelessWidget {
	@override Widget build (BuildContext context) => Drawer (
		child: ListView (
			children: [
				DrawerHeader (child: Image.asset ("lib/logo.jpg")),
				ListTile (
					title: Text ("Home"),
					leading: Icon (Icons.home),
					onTap: () => Navigator.of(context).pushReplacementNamed("home")
				),
				ListTile (
					title: Text ("Lunch"),
					leading: Icon (Icons.fastfood),
					onTap: () => Navigator.of(context).pushReplacementNamed("lunch")
				),
				ListTile (
					title: Text ("Schedule"),
					leading: Icon (Icons.schedule),
					onTap: () => Navigator.of(context).pushReplacementNamed("schedule")
				),
				ListTile (
					title: Text ("News"),
					leading: Icon (Icons.new_releases),
					onTap: () => Navigator.of(context).pushReplacementNamed("news"),
				),
				ListTile (
					title: Text ("Lost and Found"),
					leading: Icon (Icons.help),
					onTap: () => Navigator.of(context).pushReplacementNamed("lost-and-found")
				),
				ListTile (
					title: Text ("Sports"),
					leading: Icon (Icons.directions_run),
					onTap: () => Navigator.of(context).pushReplacementNamed("sports")
				),
				Expanded (child: Container()),
				ListTile (
					title: Text ("Ramaz.org"),
					leading: Icon (Icons.open_in_new),
					onTap: () => openUrl (RAMAZ)
				),
				ListTile (
					title: Text ("Ramaz email"),
					leading: Icon (Icons.open_in_new),
					onTap: () => openUrl (EMAIL)
				),
				ListTile (
					title: Text ("Schoology"),
					leading: Icon (Icons.open_in_new),
					onTap: () => openUrl (RAMAZ)
				),
				ListTile (
					title: Text ("Ramaz.org"),
					leading: Icon (Icons.open_in_new),
					onTap: () => openUrl (RAMAZ)
				),

			]
		)
	);

	void openUrl (String url) {
		print ("TODO");
	}
}