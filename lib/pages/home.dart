import "package:flutter/material.dart";
import "dart:async";

// Backend tools
import "package:ramaz/data/schedule.dart";

// Dataclasses
import "package:ramaz/services/reader.dart";
import "package:ramaz/services/auth.dart" as Auth;

// Misc
import "package:ramaz/mock/day.dart" show getToday;

// UI
import "package:ramaz/pages/drawer.dart";
import "package:ramaz/widgets/class_list.dart";
import "package:ramaz/widgets/next_class.dart";
import "package:ramaz/widgets/lunch.dart";
import "package:ramaz/widgets/icons.dart";

class HomePage extends StatefulWidget {
	final Reader reader;
	HomePage (this.reader);

	@override HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	static final today = getToday();
	static const Duration minute = Duration (minutes: 1);

	final GlobalKey<ScaffoldState> key = GlobalKey();
	Schedule schedule;
	Period period, nextPeriod;
	List<Period> periods;
	int periodIndex;
	Timer timer;
	bool needsGoogleSignIn = false; 

	@override void initState() {
		super.initState();
		Auth.needsGoogleSupport().then (
			(bool value) => setState(
				() => needsGoogleSignIn = value
			)
		);
		timer = Timer.periodic (minute, update);
		schedule = widget.reader.student.schedule [today.letter];
		periods = widget.reader.student.getPeriods (today);
		update();
	}

	@override void dispose() {
		timer.cancel();
		super.dispose();
	}

	List<Widget> get actions {
		List<Widget> result = [
			FlatButton (
				child: Text (
					"Swipe left for schedule",
					style: TextStyle (color: Colors.white)),
				onPressed: () => key.currentState.openEndDrawer()
			),
		];
		if (needsGoogleSignIn) result.insert (
			0, 
			IconButton (
				icon: Logos.google,
				onPressed: addGoogleSignIn
			)
		);
		return result;
	}

	@override Widget build (BuildContext context) => Scaffold (
		key: key,
		appBar: AppBar (
			title: Text ("Home"),
			actions: actions,
		),
		drawer: NavigationDrawer(),
		endDrawer: Drawer (
			child: ClassList(
				periods: nextPeriod == null 
					? periods
					: periods.getRange (
					(periodIndex ?? -1) + 1, periods.length
				),
				reader: widget.reader,
				headerText: period == null ? "Today's Schedule" : "Upcoming Classes"
			)
		),
		body: RefreshIndicator (  // so you can refresh the period
			onRefresh: update,
			child: ListView (
				children: [
					RamazLogos.ram_rectangle,
					Divider(),
					Center (
						child: Text (
							"Today is a${today.n} ${today.name}", 
							textScaleFactor: 2.5
						)
					),
					NextClass(period, widget.reader.subjects[period?.id]),
					nextPeriod == null  // if school is not over, show the next class
						? Container() 
						: NextClass (
								nextPeriod, 
								widget.reader.subjects[nextPeriod?.id], 
								next: true
							),
					LunchTile (lunch: today.lunch),
				]
			)
		)
	);

	Future<void> update([_]) async => setState(() {
		periodIndex = today.period;
		period = periodIndex == null ? null : periods [periodIndex];	
		if (periodIndex != null && periodIndex < periods.length - 1)
			nextPeriod = periods [periodIndex + 1];
	});

	void addGoogleSignIn() async {
		final account = await Auth.signInWithGoogle(
			() => key.currentState.showSnackBar(
				SnackBar (
					content: Text ("You need to sign in with your Ramaz email")
				)
			),
			link: true
		);
		if (account == null) return;
		else showDialog (
			context: context,
			builder: (BuildContext context) => AlertDialog(
				title: Text ("Google sign in enabled"),
				content: ListTile (
					title: Text (
						"You can now sign in with your Google account"
						// "Note that you can no longer using your password"
					)
				),
				actions: [
					FlatButton (
						child: Text ("OK"),
						onPressed: () {
							setState(() => needsGoogleSignIn = false);
							Navigator.of(context).pop();
						}
					)
				]
			)
		);
	}
}