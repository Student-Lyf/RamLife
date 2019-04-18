import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';

import "../constants.dart";  // for route names

class NavigationDrawer extends StatelessWidget {
	@override Widget build (BuildContext context) => Drawer (
		child: ListView (
			children: [
				DrawerHeader (child: Image.asset ("lib/logo.jpg")),
				ListTile (
					title: Text ("Home"),
					leading: Icon (Icons.home),
					onTap: () => Navigator.of(context).pushReplacementNamed(HOME_PAGE)
				),
				ListTile (
					title: Text ("Schedule"),
					leading: Icon (Icons.schedule),
					onTap: () => Navigator.of(context).pushReplacementNamed(SCHEDULE)
				),
				ListTile (
					title: Text ("Newspapers"),
					leading: Icon (Icons.new_releases),
					onTap: () => Navigator.of(context).pushReplacementNamed(NEWS),
				),
				ListTile (
					title: Text ("Lost and Found"),
					leading: Icon (Icons.help),
					onTap: () => Navigator.of(context).pushReplacementNamed(LOST_AND_FOUND)
				),
				ListTile (
					title: Text ("Sports"),
					leading: Icon (Icons.directions_run),
					onTap: () => Navigator.of(context).pushReplacementNamed(SPORTS)
				),
				ListTile (
					title: Text ("Admin console"),
					leading: Icon (Icons.verified_user),
					onTap: () => Navigator.of(context).pushReplacementNamed(ADMIN_LOGIN)
				),
				ListTile (
					title: Text ("Logout"),
					leading: Icon (Icons.lock),
					onTap: () => Navigator.of(context).pushReplacementNamed(LOGIN)
				),
				SizedBox (height: 30),
				Divider(),
				ListTile (
					title: Text ("Ramaz.org"),
					leading: Icon (Icons.open_in_new),
					onTap: () => launch (RAMAZ)
				),
				ListTile (
					title: Text ("Ramaz email"),
					leading: Icon (Icons.open_in_new),
					onTap: () => launch (EMAIL)
				),
				ListTile (
					title: Text ("Schoology"),
					leading: Icon (Icons.open_in_new),
					onTap: () => launch (SCHOOLOGY)
				),
				ListTile (
					title: Text ("My Backpack"),
					leading: Icon (Icons.open_in_new),
					onTap: () => launch (MY_BACKPACK)
				),

			]
		)
	);
}