import "package:flutter/material.dart";

import "package:ramaz/widgets.dart";

import "package:ramaz/constants.dart";  // for route names

class NavigationDrawer extends StatelessWidget {
	static pushRoute(BuildContext context, String name) => 
		() => Navigator.of(context).pushReplacementNamed(name);

	const NavigationDrawer({Key key}) : super(key: key);

	@override Widget build (BuildContext context) => Drawer (
		child: Column (
			children: [
				DrawerHeader (child: RamazLogos.ram_square),
				ListTile (
					title: Text ("Home"),
					leading: Icon (Icons.home),
					onTap: pushRoute(context, Routes.home),
				),
				ListTile (
					title: Text ("Schedule"),
					leading: Icon (Icons.schedule),
					onTap: pushRoute(context, Routes.schedule),
				),
				ListTile (
					title: Text ("Notes"),
					leading: Icon (Icons.note),
					onTap: pushRoute(context, Routes.notes),
				),
				BrightnessChanger.dropdown(prefs: Services.of(context).prefs),
				// ListTile (
				// 	title: Text ("Newspapers (coming soon)"),
				// 	leading: Icon (Icons.new_releases),
				// 	onTap: () => Navigator.of(context).pushReplacementNamed(NEWS),
				// ),
				// ListTile (
				// 	title: Text ("Lost and Found (coming soon)"),
				// 	leading: Icon (Icons.help),
				// 	onTap: () => Navigator.of(context).pushReplacementNamed(LOST_AND_FOUND)
				// ),
				// ListTile (
				// 	title: Text ("Sports (coming soon)"),
				// 	leading: Icon (Icons.directions_run),
				// 	onTap: () => Navigator.of(context).pushReplacementNamed(SPORTS)
				// ),
				// Divider(),
				ListTile (
					title: Text ("Logout"),
					leading: Icon (Icons.lock),
					onTap: pushRoute(context, Routes.login)
				),
				ListTile (
					title: Text ("Send Feedback"),
					leading: Icon (Icons.feedback),
					onTap: () => Navigator.of(context)
						..pop()
						..pushNamed(Routes.feedback)
				),
				AboutListTile (
					icon: Icon (Icons.info),
					child: Text ("About"),
					applicationName: "Ramaz Student Life",
					applicationVersion: "0.5",
					applicationIcon: Logos.ramazIcon,
					aboutBoxChildren: [
						Text (
							"Created by the Ramaz Coding Club (Levi Lesches and Sophia "
							"Kremer) with the support of the Ramaz administration. "
						),
						SizedBox (height: 20),
						Text (
							"A special thanks to Mr. Vovsha for helping us go from idea to "
							"reality."
						),
					]
				),
				Spacer(),
				Align (
					alignment: Alignment.bottomCenter,
					child: Column (
						children: [
							Divider(),
							SingleChildScrollView (
								scrollDirection: Axis.horizontal,
								child: Row (
									children: [
										Logos.ramazIcon,
										Logos.outlook,
										Logos.schoology,
										Logos.drive,
										Logos.senior_systems
									]
								)
							)
						]
					)
				)
			]
		)
	);
}
