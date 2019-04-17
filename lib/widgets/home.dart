// Verify: Light blue color
// TODO: add border radius for InfoCard

import "package:flutter/material.dart";
import "dart:async";

// Backend tools
import "../backend/schedule.dart";
import "../backend/student.dart";
import "../mock.dart" show getToday;

// UI
import "schedule.dart" show NextClass, ClassList;
import "drawer.dart";
import "lunch.dart" show LunchTile;

class InfoCard extends StatelessWidget {
	final String title, subtitle;
	const InfoCard (this.title, [this.subtitle]);

	@override Widget build (BuildContext context) => Card (
		child: ListTile (
			title: Text (
				title, 
				style: TextStyle (
					fontSize: 25
				)
			),
			subtitle: subtitle == null ? null : Text (
				subtitle,
				style: TextStyle (
					fontSize: 18
				)
			)
		)
	);
}

class HomePage extends StatefulWidget {
	final Student student;
	HomePage (this.student);

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

	@override void initState() {
		super.initState();
		timer = Timer.periodic (minute, update);
		schedule = widget.student.schedule [today.letter];
		periods = widget.student.getPeriods (today);
		periodIndex = today.period;
		periodIndex = 6;
		period = periodIndex == null 
			? null
			: periods [periodIndex];
	}

	@override void dispose() {
		timer.cancel();
		super.dispose();
	}

	@override Widget build (BuildContext context) => Scaffold (
		key: key,
		appBar: AppBar (
			title: Text ("Home"),
			actions: [FlatButton (
				child: Text (
					"Swipe from left to see more",
					style: TextStyle (color: Colors.white)),
				onPressed: () => key.currentState.openEndDrawer()
			)]
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
				NextClass(period),
				LunchTile (lunch: today.lunch),
				InfoCard("TODO: Sports"),
			]
		)
	);

	void update(_) => setState(() {
		periodIndex = today.period;
		period = periodIndex == null ? null : periods [periodIndex];	
	});
}