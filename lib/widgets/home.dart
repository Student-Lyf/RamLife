import "package:flutter/material.dart";
import "dart:async";

// Backend tools
import "../backend/schedule.dart";
import "../backend/student.dart";
import "../mock.dart" show getToday;
import "../constants.dart" show SPORTS;

// UI
import "schedule.dart" show NextClass, ClassList;
import "drawer.dart";
import "lunch.dart";
import "info_card.dart";

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
					"Swipe from left to see schedule",
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
}