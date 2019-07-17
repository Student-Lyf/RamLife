import "package:flutter/material.dart";

import "package:ramaz/widgets/icons.dart";
import "package:ramaz/widgets/theme_changer.dart";

import "package:ramaz/services/preferences.dart";

import "package:ramaz/constants.dart";  // for route names

class NavigationDrawer extends StatefulWidget {
	final Preferences prefs;
	NavigationDrawer(this.prefs, {Key key}) : super (key: key);

	@override
	DrawerState createState() => DrawerState();
}

class DrawerState extends State<NavigationDrawer> {
	Brightness brightness;

	@override void initState() {
		super.initState();
		final bool userPreference = widget.prefs.brightness;
		if (userPreference != null) brightness = userPreference 
			? Brightness.light
			: Brightness.dark;
	}

	@override Widget build (BuildContext context) => Drawer (
		key: widget.key,
		child: ListView (
			children: [
				DrawerHeader (child: RamazLogos.ram_square),
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
					title: Text ("Newspapers (coming soon)"),
					leading: Icon (Icons.new_releases),
					onTap: () => Navigator.of(context).pushReplacementNamed(NEWS),
				),
				ListTile (
					title: Text ("Lost and Found (coming soon)"),
					leading: Icon (Icons.help),
					onTap: () => Navigator.of(context).pushReplacementNamed(LOST_AND_FOUND)
				),
				ListTile (
					title: Text ("Sports (coming soon)"),
					leading: Icon (Icons.directions_run),
					onTap: () => Navigator.of(context).pushReplacementNamed(SPORTS)
				),
				ListTile (
					title: Text ("Admin console (coming soon)"),
					leading: Icon (Icons.verified_user),
					onTap: () => Navigator.of(context).pushReplacementNamed(ADMIN_LOGIN)
				),
				ListTile (
					title: Text ("Logout"),
					leading: Icon (Icons.lock),
					onTap: () => Navigator.of(context).pushReplacementNamed(LOGIN)
				),
				ListTile (
					title: Text ("Send Feedback"),
					leading: Icon (Icons.feedback),
					onTap: () {
						final NavigatorState nav = Navigator.of(context);
						nav.pop();
						nav.pushNamed(FEEDBACK);
					}
				),
				ListTile (
					title: Text ("Change theme"),
					leading: Icon (
						brightness == null 
							? Icons.brightness_auto
							: brightness == Brightness.light
								? Icons.brightness_5
								: Icons.brightness_4
					),
					trailing: DropdownButton<Brightness> (
						onChanged: (Brightness value) => setState(() {
							// (
							// 	context.ancestorStateOfType(
							// 		const TypeMatcher<DrawerControllerState>()
							// 	) as DrawerControllerState
							// ).close();
							ThemeChanger.of(context).brightness = value
								?? MediaQuery.of(context).platformBrightness;
							if (value == null) {
								brightness = null;
								widget.prefs.brightness = null;
							}
							else {
								widget.prefs.brightness = value == Brightness.light;
								brightness = value;
							}
						}),
						value: brightness,
						items: [
							DropdownMenuItem<Brightness> (
								value: null,
								child: Text ("Automatic")
							),
							DropdownMenuItem<Brightness> (
								value: Brightness.light,
								child: Text ("Light theme")
							),
							DropdownMenuItem<Brightness> (
								value: Brightness.dark,
								child: Text ("Dark theme"),
							),
						]
					)
				),
				AboutListTile (
					icon: Icon (Icons.info),
					child: Text ("About"),
					applicationName: "Ramaz Student Life",
					applicationVersion: "0.5",
					applicationIcon: Logos.ramazIcon,
					aboutBoxChildren: [
						Text (
							"Created by the Ramaz Coding Club (Levi Lesches, Sophia Kremer, "
							"and Sam Low) with the support of the Ramaz administration. "
						),
						SizedBox (height: 20),
						Text (
							"A special thanks to Mr. Vovsha for helping us go from idea to "
							"reality."
						),
					]
				),
				SizedBox (height: 10),
				Divider(),
				SingleChildScrollView (
					physics: NeverScrollableScrollPhysics(),
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
	);
}
