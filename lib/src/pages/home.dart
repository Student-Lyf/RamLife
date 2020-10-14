// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
import "package:ramaz/widgets.dart";

/// The homepage of the app. 
class HomePage extends StatelessWidget {
	/// Downloads the calendar again and calls [Schedule.onNewPeriod].
	Future<void> refresh(BuildContext context) async {
		try {
			await Services.instance.database.updateCalendar();
			await Services.instance.database.updateSports();
			await Models.schedule.initCalendar();
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
	Widget build (BuildContext context) => AnimatedBuilder(
		animation: Listenable.merge([Models.schedule, Models.sports]),
		builder: (BuildContext context, _) => Scaffold (
			appBar: AppBar (
				title: const Text ("Home"),
				actions: [
					if (Models.schedule.hasSchool) Builder (
						builder: (BuildContext context) => FlatButton(
							textColor: Colors.white,
							onPressed: () => Scaffold.of(context).openEndDrawer(),
							child: const Text ("Tap for schedule"),
						)
					)
				],
			),
			drawer: NavigationDrawer(),
			endDrawer: !Models.schedule.hasSchool ? null : Drawer (
				child: ClassList(
					day: Models.schedule.today,
					periods: Models.schedule.nextPeriod == null 
						? Models.schedule.periods
						: Models.schedule.periods.getRange (
							(Models.schedule.periodIndex ?? -1) + 1, 
							Models.schedule.periods.length
						),
					headerText: Models.schedule.period == null 
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
							Models.schedule.hasSchool
								? "Today is a${Models.schedule.today.n} "
									"${Models.schedule.today.name}"
									"\nSchedule: ${Models.schedule.today.special.name}"
								: "There is no school today",
							textScaleFactor: 2,
							textAlign: TextAlign.center
						),
						const SizedBox (height: 20),
						if (Models.schedule.hasSchool) NextClass(
							reminders: Models.reminders.currentReminders,
							period: Models.schedule.period,
							subject: Models.schedule.subjects [Models.schedule.period?.id],
							modified: Models.schedule.today.isModified,
						),
						// if school won't be over, show the next class
						if (
							Models.schedule.nextPeriod != null && 
							!Models.schedule.today.isModified
						) NextClass (
							next: true,
							reminders: Models.reminders.nextReminders,
							period: Models.schedule.nextPeriod,
							subject: Models.schedule.subjects [Models.schedule.nextPeriod?.id],
							modified: Models.schedule.today.isModified,
						),
						if (Models.sports.todayGames.isNotEmpty) ...[
							const SizedBox(height: 10),
							const Center(
								child: Text(
									"Sports games",
									textScaleFactor: 1.5,
									style: TextStyle(fontWeight: FontWeight.w300)
								)
							),
							const SizedBox(height: 10),
							for (final int index in Models.sports.todayGames)
								SportsTile(Models.sports.games [index])
						]
					]
				)
			)
		)
	);
}
