// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
import "package:ramaz/widgets.dart";

/// The homepage of the app. 
class HomePage extends StatelessWidget {
	final Schedule scheduleModel;
	final Reminders remindersModel; 
	final Sports sportsModel;

	HomePage() : 
		scheduleModel = Models.instance.schedule,
		remindersModel = Models.instance.reminders,
		sportsModel = Models.instance.sports;

	/// Downloads the calendar again and calls [Schedule.onNewPeriod].
	Future<void> refresh(BuildContext context) async {
		try {
			await Services.instance.database.updateCalendar();
			await Services.instance.database.updateSports();
			await scheduleModel.initCalendar();
		} on PlatformException catch(error) {
			if (error.code == "Error performing get") {
				Scaffold.of(context).showSnackBar(
					SnackBar(
						content: const Text("No Internet"), 
						action: SnackBarAction(
							label: "RETRY", 
							onPressed: () => refresh(context),
						),
					)
				);
			}
		}
	}

	@override 
	Widget build (BuildContext context) => ModelListener<HomeModel>(
		model: () => HomeModel(),
		builder: (BuildContext context, _, __) => Scaffold (
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
			body: RefreshIndicator (  // so you can refresh the period
				onRefresh: () => refresh(context),
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
	);
}
