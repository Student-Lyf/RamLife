import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";
import "drawer.dart";

/// The names of the weekdays.
const List<String> weekdayNames = [
	"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
];

/// Shows relevant info about today on the home page. 
class DashboardPage extends StatelessWidget {
	/// Allows the user to refresh data. 
	/// 
	/// Updates the calendar and sports games. To update the user profile, 
	/// log out and log back in. 
	/// 
	/// This has to be a separate function since it can recursively call itself. 
	Future<void> refresh(BuildContext context, DashboardModel model) => model.refresh(
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
	Widget build(BuildContext context) => ProviderConsumer(
		create: DashboardModel.new,
		builder: (model, child) => ResponsiveScaffold(
			enableNavigation: true,
			drawer: const RamlifeDrawer(),
			appBar: AppBar(
				title: const Text("Dashboard"),
				actions: [
					ResponsiveBuilder(
						builder: (_, LayoutInfo layout, __)  =>
							!layout.hasStandardSideSheet && model.schedule.hasSchool
							? Builder(
									builder: (BuildContext context) => IconButton(
										onPressed: () => Scaffold.of(context).openEndDrawer(),
										icon: const Icon(Icons.schedule, color: Colors.white),
									)
								)
							: const SizedBox.shrink()
					)
				]
			),
			sideSheet: !model.schedule.hasSchool 
				? null : Drawer(child: ClassList.fromSchedule(model.schedule)),
			body: RefreshIndicator(
				onRefresh: () => refresh(context, model),
				child: ListView(
					padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
					children: [
						Text (
							model.schedule.today == null
								? "There is no school today"
								: "Today is ${model.schedule.today!.name}",
							style: Theme.of(context).textTheme.displaySmall,
							textAlign: TextAlign.center
						),
						const SizedBox (height: 20),
						if (model.schedule.hasSchool) ...[
							ScheduleSlot(),
							const SizedBox(height: 10),
						],
						if (model.sports.todayGames.isNotEmpty) ...[
							Text(
								"Sports games",
								textAlign: TextAlign.center,
								style: Theme.of(context).textTheme.headlineSmall,
							),
							const SizedBox(height: 10),
							for (final int index in model.sports.todayGames)
								SportsTile(model.sports.games [index])
						]
					]
				)
			)
		),
	);
}

/// Holds the schedule info on the home page.
class ScheduleSlot extends StatelessWidget {
	/// The schedule data model.
	late final ScheduleModel scheduleModel;

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
						? "Schedule: ${scheduleModel.today!.schedule.name}"
						: "There is no school today",
					textAlign: TextAlign.center,
					style: Theme.of(context).textTheme.headlineSmall,
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
