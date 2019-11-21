// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

class HomePage extends StatefulWidget {
	@override
	HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
	bool loading = false;

	@override 
	Widget build (BuildContext context) => ModelListener<Schedule>(
		model: () => Services.of(context).schedule,
		dispose: false,
		builder: (BuildContext context, Schedule schedule, _) => Scaffold (
			key: scaffoldKey,
			appBar: AppBar (
				title: const Text ("Home"),
				actions: [
					if (schedule.hasSchool) Builder (
						builder: (BuildContext context) => FlatButton(
							textColor: Colors.white,
							onPressed: () => Scaffold.of(context).openEndDrawer(),
							child: const Text ("Tap for schedule"),
						)
					)
				],
			),
			drawer: NavigationDrawer(),
			endDrawer: !schedule.hasSchool ? null : Drawer (
				child: ClassList(
					day: schedule.today,
					periods: schedule.nextPeriod == null 
						? schedule.periods
						: schedule.periods.getRange (
							(schedule.periodIndex ?? -1) + 1, 
							schedule.periods.length
						),
					headerText: schedule.period == null 
						? "Today's Schedule" 
						: "Upcoming Classes"
				)
			),
			body: RefreshIndicator (  // so you can refresh the period
				onRefresh: () {
					Future<void> downloadCalendar() async {
						try {
							await Services.of(context).services.updateCalendar();
						} on PlatformException catch(error) {
							if (error.code == "Error performing get") {
								scaffoldKey.currentState.showSnackBar(
									SnackBar(
										content: const Text("No internet"), 
										action: SnackBarAction(
											label: "RETRY", 
											onPressed: () async {
												setState(() => loading = true);
												await downloadCalendar();
												setState(() => loading = false);
											}
										),
									)
								);
							}
							schedule.onNewPeriod();
						}
					}
					return downloadCalendar;
				}(),
				child: ListView (
					children: [
						if (loading) const LinearProgressIndicator(),
						RamazLogos.ramRectangle,
						const Divider(),
						Text (
							schedule.hasSchool
								? "Today is a${schedule.today.n} "
									"${schedule.today.name}"
								: "There is no school today",
							textScaleFactor: 2,
							textAlign: TextAlign.center
						),
						const SizedBox (height: 20),
						if (schedule.hasSchool) NextClass(
							reminders: schedule.reminders.currentReminders,
							period: schedule.period,
							subject: schedule.subjects [schedule.period?.id],
							modified: schedule.today.isModified,
						),
						// if school won't be over, show the next class
						if (schedule.nextPeriod != null && !schedule.today.isModified) NextClass (
							next: true,
							reminders: schedule.reminders.nextReminders,
							period: schedule.nextPeriod,
							subject: schedule.subjects [schedule.nextPeriod?.id],
							modified: schedule.today.isModified,
						),
					]
				)
			)
		)
	);
}
