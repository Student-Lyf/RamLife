// ignore_for_file: prefer_const_constructors
import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// A drawer to show throughout the app.
class NavigationDrawer extends StatelessWidget {
	/// Uses the navigator to launch a page by name.
	static Future<void> Function() pushRoute(BuildContext context, String name) => 
		() => Navigator.of(context).pushReplacementNamed(name);

	const NavigationDrawer();

	String? getRouteName(BuildContext context) => 
		ModalRoute.of(context)!.settings.name;

	bool get isScheduleAdmin => Models.instance.user
		.adminScopes!.contains(AdminScope.calendar);

	bool get isSportsAdmin => Models.instance.user
		.adminScopes!.contains(AdminScope.sports);

	@override 
	Widget build (BuildContext context) => ResponsiveBuilder(
		builder: (_, LayoutInfo layout, __) => Drawer (
			child: LayoutBuilder(
				builder: (
					BuildContext context, 
					BoxConstraints constraints
				) => SingleChildScrollView(
					child: ConstrainedBox(
						constraints: BoxConstraints(
							minHeight: constraints.maxHeight,
						),
						child: IntrinsicHeight(
							child: Column(
								children: [
									DrawerHeader(child: RamazLogos.ramSquare),
									if (layout.isDesktop || getRouteName(context) != Routes.home)
										ListTile (
											title: const Text ("Dashboard"),
											leading: Icon (Icons.dashboard),
											onTap: pushRoute(context, Routes.home),
										),
									if (layout.isDesktop || getRouteName(context) != Routes.schedule)
										ListTile (
											title: const Text ("Schedule"),
											leading: Icon (Icons.schedule),
											onTap: pushRoute(context, Routes.schedule),
										),
									if (layout.isDesktop || getRouteName(context) != Routes.reminders)
										ListTile (
											title: const Text ("Reminders"),
											leading: Icon (Icons.notifications),
											onTap: pushRoute(context, Routes.reminders),
										),
									ListTile (
										title: Text ("Sports"),
										leading: Icon (Icons.sports),
										onTap: pushRoute(context, Routes.sports),
									),
									if (Models.instance.user.isAdmin) ExpansionTile(
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
													onTap: pushRoute(context, Routes.specials),
												),
											],
											if (isSportsAdmin) 
												ListTile(
													title: Text("Sports"),
													leading: Icon(Icons.sports),
													onTap: pushRoute(context, Routes.sports),
												)
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
									const AboutListTile (
										icon: Icon (Icons.info),
										// ignore: sort_child_properties_last
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
									const Spacer(),
									Align (
										alignment: Alignment.bottomCenter,
										child: Column (
											children: [
												const Divider(),
												SingleChildScrollView (
													scrollDirection: Axis.horizontal,
													child: Row (
														children: const [
															Logos.ramazIcon,
															Logos.outlook,
															Logos.schoology,
															Logos.drive,
															Logos.seniorSystems
														]
													)
												)
											]
										)
									)
								]
							)
						) 
					)
				)
			)
		)
	);
}
