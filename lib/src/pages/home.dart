// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
import "package:ramaz/widgets.dart";

/// The homepage of the app. 
/// 
/// It's stateful because when refreshing the schedule a loading bar is shown,
/// and needs to be dismissed. However, it can be rewritten to use a 
/// [ValueNotifier] instead.
class HomePage extends StatefulWidget {
	@override
	HomePageState createState() => HomePageState();
}

/// A state for the home page, to keep track of when the page loads. 
class HomePageState extends State<HomePage> {
	/// A key to access the [Scaffold]s state. 
	final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

	/// Whether the page is loading. 
	bool loading = false;

	/// Downloads the calendar again and calls [Schedule.onNewPeriod].
	Future<void> refresh() async {
		try {
			await Services.instance.updateCalendar();
			await Services.instance.updateSports();
		} on PlatformException catch(error) {
			if (error.code == "Error performing get") {
				scaffoldKey.currentState.showSnackBar(
					SnackBar(
						content: const Text("No Internet"), 
						action: SnackBarAction(
							label: "RETRY", 
							onPressed: () async {
								setState(() => loading = true);
								await refresh();
								setState(() => loading = false);
							}
						),
					)
				);
			}
		}
	}

	@override 
	Widget build (BuildContext context) => ModelListener<HomeModel>(
		model: () => HomeModel(),
		builder: (BuildContext context, HomeModel model, _) => Scaffold (
			key: scaffoldKey,
			appBar: AppBar (
				title: const Text ("Home"),
				actions: [
					if (model.schedule.hasSchool) Builder (
						builder: (BuildContext context) => FlatButton(
							textColor: Colors.white,
							onPressed: () => Scaffold.of(context).openEndDrawer(),
							child: const Text ("Tap for schedule"),
						)
					)
				],
			),
			drawer: NavigationDrawer(),
			endDrawer: !model.schedule.hasSchool ? null : Drawer (
				child: ClassList(
					day: model.schedule.today,
					periods: model.schedule.nextPeriod == null 
						? model.schedule.periods
						: model.schedule.periods.getRange (
							(model.schedule.periodIndex ?? -1) + 1, 
							model.schedule.periods.length
						),
					headerText: model.schedule.period == null 
						? "Today's Schedule" 
						: "Upcoming Classes"
				)
			),
			body: RefreshIndicator (  // so you can refresh the period
				onRefresh: refresh,
				child: ListView (
					children: [
						if (loading) const LinearProgressIndicator(),
						RamazLogos.ramRectangle,
						const Divider(),
						Text (
							model.schedule.hasSchool
								? "Today is a${model.schedule.today.n} "
									"${model.schedule.today.name}"
								: "There is no school today",
							textScaleFactor: 2,
							textAlign: TextAlign.center
						),
						const SizedBox (height: 20),
						if (model.schedule.hasSchool) NextClass(
							reminders: Models.reminders.currentReminders,
							period: model.schedule.period,
							subject: model.schedule.subjects [model.schedule.period?.id],
							modified: model.schedule.today.isModified,
						),
						// if school won't be over, show the next class
						if (
							model.schedule.nextPeriod != null && 
							!model.schedule.today.isModified
						) NextClass (
							next: true,
							reminders: Models.reminders.nextReminders,
							period: model.schedule.nextPeriod,
							subject: model.schedule.subjects [model.schedule.nextPeriod?.id],
							modified: model.schedule.today.isModified,
						),
						if (model.sports.todayGames.isNotEmpty) ...[
							const SizedBox(height: 10),
							const Center(
								child: Text(
									"Sports games",
									textScaleFactor: 1.5,
									style: TextStyle(fontWeight: FontWeight.w300)
								)
							),
							const SizedBox(height: 10),
							for (final int index in model.sports.todayGames)
								SportsTile(model.sports.games [index])
						]
					]
				)
			)
		)
	);
}
