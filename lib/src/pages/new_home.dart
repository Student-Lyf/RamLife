import "package:flutter/material.dart";
import "package:breakpoint_scaffold/breakpoint_scaffold.dart";

import "package:ramaz/models.dart";

import "drawer.dart";
import "home.dart";
import "reminders.dart";
import "responsive_page.dart";
import "schedule.dart";

class HomePage extends StatefulWidget {
	final int? pageIndex;
	const HomePage({this.pageIndex});

	@override
	HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	static const List<NavigationItem> navItems = [
		NavigationItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
		NavigationItem(icon: Icon(Icons.schedule), label: "Schedule"),
		NavigationItem(icon: Icon(Icons.notifications), label: "Reminders"),
	];

	late int index;

	@override
	void initState() {
		super.initState();
		index = widget.pageIndex ?? 0;
	}

	final List<ResponsivePage> data = [
		Dashboard(),
		ResponsiveSchedule(),
		ResponsiveReminders(),
	];

	@override
	Widget build(BuildContext context) => ResponsiveBuilder(
		builder: (_, LayoutInfo layout, __) => ResponsiveScaffold.navBar(
			navItems: navItems,
			navIndex: index,
			onNavIndexChanged: (int value) => setState(() => index = value),
			appBar: data [index].appBar,
			drawer: NavigationDrawer(),
			secondaryDrawer: NavigationDrawer(isOnHomePage: true),
			sideSheet: data [index].sideSheet,
			body: data [index].builder(context),
			floatingActionButton: data [index].floatingActionButton,
			floatingActionButtonLocation: data [index].floatingActionButtonLocation,
		)
	);
}
