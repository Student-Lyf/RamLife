// Verify: Light blue color
// TODO: add border radius for InfoCard

import "package:flutter/material.dart";
import "drawer.dart";
import "schedule.dart" show NextClass, ClassList;
import "../backend/schedule.dart";
// import "../backend/times.dart";
import "../backend/student.dart";
import "../mock.dart" show getToday;

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
	final GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

	Schedule schedule;
	List<Period> periods;
	int periodIndex;
	Period period;

	@override void initState() {
		super.initState();
		schedule = widget.student.schedule [today.letter];
		periods = widget.student.getPeriods (today);
		periodIndex = today.period;
		period = periodIndex == null 
			? null
			: periods [periodIndex];
	}

	@override Widget build (BuildContext context) => Scaffold (
		key: key,
		appBar: AppBar (
			title: Text ("Home"),
			actions: [FlatButton (
				child: Text ("Swipe from left see more", textScaleFactor: 0.9, style: TextStyle (color: Colors.white)),
				onPressed: key.currentState.openEndDrawer
			)]
		),
		drawer: NavigationDrawer(),
		endDrawer: Drawer (
			child: ClassList(
				periods.getRange (periodIndex ?? 0, periods.length)
			)
		),
		body: Column (
			children: [
				NextClass(period),
				InfoCard("This is today's lunch"),
				InfoCard("These are today's sports games")
			]
		)
	);
}