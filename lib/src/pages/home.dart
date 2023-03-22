import "package:flutter/material.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";
import "dashboard.dart";

/// The home page of RamLife.
/// 
/// The home page combines different helpful pages. For good UI, limit this to 
/// 3-5 pages. Other pages should go in the side menu. 
class HomePage extends StatelessWidget {
	/// Which sub-page should be shown by default.  
	final int pageIndex;

	/// Creates the home page, starting at a certain sub-page if necessary.
	/// 
	/// Use this for app-wide navigation. For example, to navigate to the reminders
	/// page, pass in 2 for [pageIndex].
	const HomePage({required this.pageIndex});

	@override
	Widget build(BuildContext context) => ResponsiveBuilder(
		// Workaround for SportsPage's tab-based view that needs a controller.
		builder: (_, LayoutInfo layout, __) => DefaultTabController(
			length: 2,
			child:ResponsiveScaffold.navBar(
				navItems: [
					Dashboard(),
					ResponsiveSchedule(),
					ResponsiveReminders(),
					SportsPage(),
				],
				initialNavIndex: pageIndex,
				drawer: const RamlifeDrawer(),
				secondaryDrawer: const RamlifeDrawer(),
			)
		),
	);
}
