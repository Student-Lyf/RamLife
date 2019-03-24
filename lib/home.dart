// TODO: refresh every minute
// VERIFY: Today is a(n) message (see comment)
// VERIFY: How many periods are left in the dropdown
// VERIFY: Times

import "package:flutter/material.dart";

import "dart:async";

import "dataclasses.dart";
import "mock.dart";
import "helpers.dart";
import "drawer.dart";


class InfoCard extends StatelessWidget {
	final String title;
	final IconData icon;
	final List <Widget> children;
	final double padding;

	const InfoCard ({
		@required this.title,
		@required this.children,
		this.icon,
		this.padding = 5
	});

	@override Widget build (BuildContext context) => ExpansionTile (
		leading: Icon (icon),
		title: Text(title),
		children: [
			Padding (
				padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
				child: Align (
					alignment: Alignment.centerLeft,
					child: Column (
						mainAxisSize: MainAxisSize.max,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: children.map (
							(Widget child) => Padding (
								padding: EdgeInsets.symmetric(vertical: padding),
								child: child
							)
						).toList()
					)
				)
			)
		]
	);
}

class HomePage extends StatefulWidget {
	final Student student;

	HomePage (this.student);

	@override HomePageState createState() => HomePageState();
}

class HomePageState extends State <HomePage> {
	final Day today = getToday();
	static Duration minute = Duration (minutes: 1);
	Schedule schedule;
	Period currentPeriod;
	Subject currentSubject;
	String special;
	List <Period> periods;
	int periodNumber;

	@override initState () {
		super.initState();
		Timer.periodic (minute, updateScreen);
		schedule = widget.student.schedule [today.letter];
		periods = widget.student.getPeriods (today);
		periodNumber = today.period;
		print (periodNumber);
		currentPeriod = periodNumber == null 
			? null
			: periods [periodNumber];
		currentSubject = getSubject (currentPeriod);
	}

	@override
	Widget build (BuildContext context) => Scaffold (
		appBar: AppBar (
			title: Text ("Ramaz")
		),

		drawer: NavigationDrawer(),

		body: ListView (
			children: [
				Card (
					child: ListTile (
						title: Text (
							currentPeriod == null
								? "School is over"
								: "Next class: ${currentSubject?.name ?? currentPeriod.period}",
							textScaleFactor: 1.5
						),
						leading: Icon (Icons.school, size: 35),
						subtitle: Column (
							crossAxisAlignment: CrossAxisAlignment.start,
							children: pad (
								padding: 5,
								children: currentPeriod?.getInfo() ?? []
							) 
						)
					)
				),

				Card (child: InfoCard (
					icon: Icons.schedule,
					padding: 1,
					title: (
						"Today is a${aOrAn (today.name)} "
						"${today.name}"
					),
					children: List.generate(
						today.special.periods.length - ((periodNumber ?? -1) + 1),
						(int index) {
							final Period period = periods[(periodNumber ?? - 1) + index + 1];
							final Subject subject = getSubject (period);
							final List <Text> info = [
								Text ("Time: ${period.time}"),
							];
							if (period.room != null) 
								info.add (Text ("Room: ${period.room}"));
							if (subject != null) 
								info.add (Text ("Teacher: ${subject.teacher}"));
							return InfoCard (
								title: "${period.period}${subject == null ? '' : ': ${subject.name}'}",
								children: info
							);
						}
					)
				)),
				Card (child: InfoCard (
					title: "Today's lunch: ${today.lunch.main}",
					icon: today.lunch.icon,
					padding: 5,
					children: [
						Text ("Main: ${today.lunch.main}"),
						Text ("Soup: ${today.lunch.soup}"),
						Text ("Side 1: ${today.lunch.side1}"),
						Text ("Side 2: ${today.lunch.side2}"),
						Text ("Salad: ${today.lunch.salad}"),
						Text ("Dessert: ${today.lunch.dessert}")
					],
				))
			]
		),
	);

	updateScreen(_) {
		setState(() {
			periodNumber = today.period;
		});
	}
}