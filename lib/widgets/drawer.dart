import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';

import "package:ramaz/constants.dart";  // for route names

class NavigationDrawer extends StatelessWidget {
	@override Widget build (BuildContext context) => Drawer (
		child: ListView (
			children: [
				DrawerHeader (child: Image.asset ("images/ram_square.png")),
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
					onTap: () => launch (RAMAZ),
					title: Text ("Ramaz.org"),
					leading: CircleAvatar (
						child: Image.asset ("images/logo.jpg")
					),
				),
				ListTile (
					onTap: () => launch (EMAIL),
					title: Text ("Ramaz email"),
					leading: CircleAvatar(
						child: Image.asset("images/outlook.jpg")
					),
				),
				ListTile (
					onTap: () => launch (SCHOOLOGY),
					title: Text ("Schoology"),
					leading: CircleAvatar(
						child: Image.asset("images/schoology.png")
					),
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