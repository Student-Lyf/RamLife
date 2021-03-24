import "package:flutter/material.dart";

import "package:adaptive_components/adaptive_components.dart";
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
		() => Scaffold.of(context).showSnackBar(
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
		builder: (_, HomeModel model, __) => ResponsiveScaffold.navBar(
			// appBarBuilder: (isShowingSchedule) => AppBar(
			appBar: AppBar(
				title: const Text ("Home"),
				actions: [
					// if (scheduleModel.hasSchool && !isShowingSchedule) Builder(
					if (scheduleModel.hasSchool) ResponsiveBuilder(
						builder: (BuildContext context, LayoutInfo info, __) => 
							info.hasStandardSideSheet ? Container() : FlatButton(
								textColor: Colors.white,
								onPressed: () => Scaffold.of(context).openEndDrawer(),
								child: const Text ("Tap for schedule"),
							)
					)
				],
			),
			drawer: ResponsiveBuilder(
				builder: (BuildContext context, LayoutInfo info, Widget drawer) => 
					info.hasStandardDrawer ? SizedBox(width: 256, child: drawer) : drawer,
				child: NavigationDrawer(),
			),
			// SizedBox(width: 256, child: NavigationDrawer()),
			sideSheet: ResponsiveBuilder(
				builder: (BuildContext context, LayoutInfo info, Widget schedule) => 
					!scheduleModel.hasSchool ? null : info.hasStandardSideSheet 
						? SizedBox(width: 320, child: schedule) : Drawer(child: schedule),
				child: ClassList(
					day: scheduleModel.today,
					periods: scheduleModel.nextPeriod == null 
						? scheduleModel.periods
						: scheduleModel.periods.getRange (
							(scheduleModel.periodIndex ?? -1) + 1, 
							scheduleModel.periods.length
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
							Text(
								scheduleModel.hasSchool
									? "Schedule: ${scheduleModel.today.special.name}"
									: "There is no school today",
								textAlign: TextAlign.center,
								style: Theme.of(context).textTheme.headline5,
							),
							const SizedBox (height: 10),
							ScheduleSlot(
								children: [
									if (scheduleModel.hasSchool) NextClass(
										reminders: remindersModel.currentReminders,
										period: scheduleModel.period,
										subject: scheduleModel.subjects [scheduleModel.period?.id],
										modified: scheduleModel.today.isModified,
									),
									if (
										scheduleModel.nextPeriod != null && 
										!scheduleModel.today.isModified
									) NextClass (
										next: true,
										reminders: remindersModel.nextReminders,
										period: scheduleModel.nextPeriod,
										subject: scheduleModel.subjects [scheduleModel.nextPeriod?.id],
										modified: scheduleModel.today.isModified,
									),
								]
							),
							if (sportsModel.todayGames.isNotEmpty) ...[
								const SizedBox(height: 10),
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
	);
}


class ScheduleSlot extends StatelessWidget {
	final List<Widget> children;
	const ScheduleSlot({@required this.children});

	@override
	Widget build(BuildContext context) => ResponsiveBuilder(
		builder: (_, LayoutInfo layout, __) => 
		layout.isDesktop && children.length > 1
			? GridView.count(
				shrinkWrap: true,
				crossAxisCount: layout.isDesktop ? children.length : 1,
				children: children
			)
			: Column(children: children)
	);
}
