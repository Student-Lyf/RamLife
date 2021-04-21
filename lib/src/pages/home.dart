import "package:flutter/material.dart";

import "package:ramaz/widgets.dart";

import "dashboard.dart";
import "drawer.dart";
import "reminders.dart";
import "schedule.dart";

/// The home page of RamLife.
/// 
/// The home page combines different helpful pages. For good UI, limit this to 
/// 3-5 pages. Other pages should go in the side menu. 
class HomePage extends StatefulWidget {
	/// Which sub-page should be shown by default.  
	final int? pageIndex;

	/// Creates the home page, starting at a certain sub-page if necessary.
	/// 
	/// Use this for app-wide navigation. For example, to navigate to the reminders
	/// page, pass in 2 for [pageIndex].
	const HomePage({this.pageIndex});

	@override
	HomePageState createState() => HomePageState();
}

/// The state for the home page.
/// 
/// Manages what page is currently loaded.
class HomePageState extends State<HomePage> {
	/// The different sub-pages.
	final List<NavigationItem> navItems = [
		Dashboard(),
		ResponsiveSchedule(),
		ResponsiveReminders(),
	];

	/// Which sub-page is currently active.
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
