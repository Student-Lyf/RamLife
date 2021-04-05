import "package:flutter/material.dart";

import "package:ramaz/widgets.dart";

import "dashboard.dart";
import "drawer.dart";
import "reminders.dart";
import "schedule.dart";

class HomePage extends StatefulWidget {
	final int? pageIndex;
	const HomePage({this.pageIndex});

	@override
	HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	final List<NavigationItem> navItems = [
		Dashboard(),
		ResponsiveSchedule(),
		ResponsiveReminders(),
	];

	late int index;

	@override
	void initState() {
		super.initState();
		index = widget.pageIndex ?? 0;
	}

	@override
	Widget build(BuildContext context) => ResponsiveBuilder(
		builder: (_, LayoutInfo layout, __) => ResponsiveScaffold.navBar(
			navItems: navItems,
			navIndex: index,
			onNavIndexChanged: (int value) => setState(() => index = value),
			drawer: const NavigationDrawer(),
			secondaryDrawer: const NavigationDrawer(),
		)
	);
}
