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
		// color: Colors.lightBlueAccent,
		child: ListTile (
			title: Text (
				title, 
				style: TextStyle (
					// color: Colors.white,
					fontSize: 25
				)
			),
			subtitle: subtitle == null ? null : Text (
				subtitle,
				style: TextStyle (
					// color: Colors.white,
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
		appBar: AppBar (
			title: Text ("Home")
			actions: [],
		),
		drawer: NavigationDrawer(),
		// bottomNavigationBar: Footer(),
		endDrawer: Drawer (
			child: ClassList(
				periods.getRange (periodIndex, periods.length)
			)
		),
		body: Column (
			children: [
				NextClass(
					// Period (
					// 	PeriodData (
					// 		room: "GYM",
					// 		id: 4
					// 	),
					// 	time: Range (
					// 		Time (8, 00), Time (8, 50)
					// 	),
					// 	period: "5"
					// ),
					period
				),
				// InfoCard("This is the class you have now", "Made you look"),
				InfoCard("This is today's lunch"),
				InfoCard("These are today's sports games")
			]
		)
	);
}