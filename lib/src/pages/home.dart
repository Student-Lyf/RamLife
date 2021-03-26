import "package:flutter/material.dart";
import "package:breakpoint_scaffold/breakpoint_scaffold.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// The homepage of the app. 
class HomePage extends StatelessWidget {
	/// The reminders data model. 
	final Reminders remindersModel; 

	/// The sports data model. 
	final Sports sportsModel;

	/// The schedule data model. 
	final Schedule scheduleModel;

	/// The home page. 
	/// 
	/// Listens to [Schedule] (and by extension, [Reminders]) and [Sports]. 
	HomePage() : 
		scheduleModel = Models.instance.schedule,
		remindersModel = Models.instance.reminders,
		sportsModel = Models.instance.sports;

	/// Allows the user to refresh data. 
	/// 
	/// Updates the calendar and sports games. To update the user profile, 
	/// log out and log back in. 
	/// 
	/// This has to be a separate function since it can recursively call itself. 
	Future<void> refresh(BuildContext context, HomeModel model) => model.refresh(
		() => ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: const Text("No Internet"), 
				action: SnackBarAction(
					label: "RETRY", 
					onPressed: () => refresh(context, model),
				),
			)
		)
	);

	@override 
	Widget build (BuildContext context) => ModelListener<HomeModel>(
		model: () => HomeModel(),
		builder: (_, HomeModel model, __) => ResponsiveBuilder(
			builder: (_, LayoutInfo layout, __) => ResponsiveScaffold.navBar(
				appBar: AppBar(
					title: const Text ("Home"),
					actions: [
						if (scheduleModel.hasSchool && !layout.hasStandardSideSheet)
							TextButton(
								onPressed: () => Scaffold.of(context).openEndDrawer(),
								child: const Text ("Tap for schedule"),
							)
					],
				),
				drawer: layout.hasStandardDrawer 
					? SizedBox(width: 256, child: NavigationDrawer()) 
					: NavigationDrawer(),
				sideSheet: !scheduleModel.hasSchool || layout.hasStandardSideSheet 
					? null
					: Drawer(
						child: ClassList(
							// if there is school, then:
							// 	scheduleModel.today != null
							// 	scheduleModel.periods != null
							day: scheduleModel.today!,  
							periods: scheduleModel.nextPeriod == null 
								? scheduleModel.periods!
								: scheduleModel.periods!.getRange (
									(scheduleModel.periodIndex ?? -1) + 1, 
									scheduleModel.periods!.length
								),
							headerText: scheduleModel.period == null 
								? "Today's Schedule" 
								: "Upcoming Classes"
						),
					),
				navItems: const [
					NavigationItem(icon: Icon(Icons.calendar_today), label: "Today"),
					NavigationItem(icon: Icon(Icons.schedule), label: "Schedule"),
					NavigationItem(icon: Icon(Icons.notifications), label: "Reminders"),
				],
				secondaryDrawer: NavigationDrawer(),
				navIndex: 0,
				onNavIndexChanged: (int value) {},
				body: Builder(
					builder: (BuildContext context) => RefreshIndicator(
						onRefresh: () => refresh(context, model),
						child: ListView(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
							children: [
								Text (
									"Today is XXX",
									style: Theme.of(context).textTheme.headline3,
									textAlign: TextAlign.center
								),
								const SizedBox (height: 20),
								ScheduleSlot(),
								const SizedBox(height: 10),
								if (sportsModel.todayGames.isNotEmpty) ...[
									Text(
										"Sports games",
										textAlign: TextAlign.center,
										style: Theme.of(context).textTheme.headline5,
									),
									const SizedBox(height: 10),
									for (final int index in sportsModel.todayGames)
										SportsTile(sportsModel.games [index])
								]
							]
						)
					)
				)
			)
		)
	);
}


/// Holds the schedule info on the home page.
class ScheduleSlot extends StatelessWidget {
	/// The schedule data model.
	late final Schedule scheduleModel;

	/// The reminders data model.
	late final Reminders remindersModel;

	/// Displays schedule info on the home page.
	ScheduleSlot() {
		final Models models = Models.instance;
		remindersModel = models.reminders;
		scheduleModel = models.schedule;
	}

	/// The [NextClass] widgets to display.
	List<Widget> get children => [
		if (scheduleModel.hasSchool) NextClass(
			reminders: remindersModel.currentReminders,
			period: scheduleModel.period,
			subject: scheduleModel.subjects [scheduleModel.period?.id],
		),
		if (scheduleModel.nextPeriod != null) NextClass(
			next: true,
			reminders: remindersModel.nextReminders,
			period: scheduleModel.nextPeriod,
			subject: scheduleModel.subjects [scheduleModel.nextPeriod?.id],
		),
	];

	@override
	Widget build(BuildContext context) => ResponsiveBuilder(
		builder: (_, LayoutInfo layout, __) => Column(
			children: [
				Text(
					scheduleModel.hasSchool
						// if there is school, then scheduleModel.today != null
						? "Schedule: ${scheduleModel.today!.special.name}"
						: "There is no school today",
					textAlign: TextAlign.center,
					style: Theme.of(context).textTheme.headline5,
				),
				const SizedBox (height: 10),
				if (layout.isDesktop && children.length > 1) GridView.count(
					shrinkWrap: true,
					crossAxisCount: layout.isDesktop ? children.length : 1,
					children: children
				) else Column(children: children)
			]
		)
	);
}
