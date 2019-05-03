import "package:flutter/material.dart";
import "dart:async";

// Backend tools
import "package:ramaz/data/schedule.dart";

// Dataclasses
import "package:ramaz/services/reader.dart";
import "package:ramaz/services/auth.dart" as Auth;

// Misc
import "package:ramaz/mock.dart" show getToday;
import "package:ramaz/constants.dart" show SPORTS;

// UI
import "package:ramaz/widgets/class_list.dart";
import "package:ramaz/widgets/next_class.dart";
import "package:ramaz/widgets/drawer.dart";
import "package:ramaz/widgets/lunch.dart";
import "package:ramaz/widgets/info_card.dart";

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
	Period period;
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
		periodIndex = today.period;
		period = periodIndex == null 
			? null
			: periods [periodIndex];
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
				icon: CircleAvatar (
					child: Image.asset ("images/google.png"),
				),
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
				periods: periods.getRange ((periodIndex ?? -1) + 1, periods.length),
				headerText: period == null ? "Today's Schedule" : "Upcoming Classes"
			)
		),
		body: ListView (
			children: [
				Image.asset (
					"images/ram_logo_rectangle.jpg"
				),
				Divider(),
				Center (
					child: Text (
						"Today is a${today.n} ${today.name}", 
						textScaleFactor: 2.5
					)
				),
				NextClass(period),
				LunchTile (lunch: today.lunch),
				InfoCard(
					title: "Sports coming soon!", 
					icon: Icons.directions_run,
					children: const [],
					page: SPORTS
				),
			]
		)
	);

	void update(_) => setState(() {
		periodIndex = today.period;
		period = periodIndex == null ? null : periods [periodIndex];	
	});

	void addGoogleSignIn() async {
		final account = await Auth.signInWithGoogle(
			() => key.currentState.showSnackBar(
				SnackBar (
					content: Text ("You need to sign in with your Ramaz email")
				)
			)
		);
		if (account == null) return;
		showDialog (
			context: context,
			builder: (BuildContext context) => AlertDialog(
				title: Text ("Google sign in enabled"),
				content: ListTile (
					title: Text (
						"You can now sign in with your Google account\n\n"
						"Note that you can no longer using your password"
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