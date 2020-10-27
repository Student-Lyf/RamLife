// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// The homepage of the app. 
class HomePage extends StatelessWidget {
	/// The schedule data model. 
	final Schedule scheduleModel;

	/// The reminders data model. 
	final Reminders remindersModel; 

	/// The sports data model. 
	final Sports sportsModel;

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
		builder: (BuildContext context, HomeModel model, __) => Scaffold (
			appBar: AppBar (
				title: const Text ("Home"),
				actions: [
					if (scheduleModel.hasSchool) Builder (
						builder: (BuildContext context) => FlatButton(
							textColor: Colors.white,
							onPressed: () => Scaffold.of(context).openEndDrawer(),
							child: const Text ("Tap for schedule"),
						)
					)
				],
			),
			drawer: NavigationDrawer(),
			endDrawer: !scheduleModel.hasSchool ? null : Drawer (
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
				)
			),
			body: Builder(
				builder: (BuildContext context) => RefreshIndicator(
					onRefresh: () => refresh(context, model),
					child: ListView (
						children: [
							RamazLogos.ramRectangle,
							const Divider(),
							Text (
								scheduleModel.hasSchool
									? "Today is a${scheduleModel.today.n} "
										"${scheduleModel.today.name}"
										"\nSchedule: ${scheduleModel.today.special.name}"
									: "There is no school today",
								textScaleFactor: 2,
								textAlign: TextAlign.center
							),
							const SizedBox (height: 20),
							if (scheduleModel.hasSchool) NextClass(
								reminders: remindersModel.currentReminders,
								period: scheduleModel.period,
								subject: scheduleModel.subjects [scheduleModel.period?.id],
								modified: scheduleModel.today.isModified,
							),
							// if school won't be over, show the next class
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
							if (sportsModel.todayGames.isNotEmpty) ...[
								const SizedBox(height: 10),
								const Center(
									child: Text(
										"Sports games",
										textScaleFactor: 1.5,
										style: TextStyle(fontWeight: FontWeight.w300)
									)
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
