// ignore_for_file: prefer_const_constructors
import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A drawer to show throughout the app.
class RamlifeDrawer extends StatelessWidget {
	/// Uses the navigator to launch a page by name.
	static Future<void> Function() pushRoute(BuildContext context, String name) => 
		() => Navigator.of(context).pushReplacementNamed(name);

	/// Creates the drawer.
	const RamlifeDrawer();

	/// Returns the current route name.
	String? getRouteName(BuildContext context) => 
		ModalRoute.of(context)!.settings.name;

	/// Whether the user is allowed to modify the calendar.
	bool get isScheduleAdmin => (Models.instance.user.adminScopes ?? [])
		.contains(AdminScope.calendar);

	/// Whether the user is allowed to modify sports. 
	bool get isSportsAdmin => (Models.instance.user.adminScopes ?? [])
		.contains(AdminScope.sports);

	@override 
	Widget build (BuildContext context) => Column(children: [
		Expanded(child: NavigationDrawer(
			selectedIndex: getDestinationIndex(context),
			onDestinationSelected: (value) => destinationCallback(context, value),
			children: [
				DrawerHeader(child: RamazLogos.ramSquare),
				...[
					for (final destination in destinations) 
						destination.drawer,
				],
				if (isScheduleAdmin) ExpansionTile(
					leading: Icon(Icons.admin_panel_settings),
					title: const Text("Admin options"),
					children: [
						if (isScheduleAdmin) ...[
							ListTile(
								title: Text("Calendar"),
								leading: Icon(Icons.calendar_today),
								onTap: pushRoute(context, Routes.calendar),
							),
							ListTile(
								title: Text("Custom schedules"),
								leading: Icon(Icons.schedule),
								onTap: pushRoute(context, Routes.schedules),
							),
						],
					]
				),
				BrightnessChanger.dropdown(),
				ListTile (
					title: const Text ("Logout"),
					leading: Icon (Icons.lock),
					onTap: pushRoute(context, Routes.login)
				),
				ListTile (
					title: const Text ("Send Feedback"),
					leading: Icon (Icons.feedback),
					onTap: pushRoute(context, Routes.feedback),
				),
				ListTile (
					title: const Text("About Us"),
					leading: Icon (Icons.info),
					onTap: pushRoute(context, Routes.credits),
				),
			]
		)),
		Material(
			elevation: 0,
			child: SingleChildScrollView (
				scrollDirection: Axis.horizontal,
				child: Row (
					crossAxisAlignment: CrossAxisAlignment.center,
					children: const [
						Logos.ramazIcon,
						Logos.outlook,
						Logos.schoology,
						Logos.drive,
						Logos.seniorSystems
					]
				)
			)
		)
	]);
}
