// TODO: refresh every minute
// VERIFY: Today is a(n) message (see comment)
// VERIFY: How many periods are left in the dropdown
// VERIFY: Times

import "package:flutter/material.dart";

import "dart:async";

import "../mock.dart";

import "../backend/schedule.dart";
import "../backend/student.dart";
import "../backend/helpers.dart";

import "drawer.dart";


List <Widget> pad ({List <Widget> children, double padding}) => children.map (
	(Widget child) => Padding (
		padding: EdgeInsets.symmetric(vertical: padding),
		child: child
	)
).toList();

class NextClass extends StatelessWidget {
	final Period period;
	const NextClass(this.period);
	static final TextStyle white = TextStyle (
		color: Colors.white
	);

	@override Widget build (BuildContext context) {
		final subject = getSubject (period);
		return Card (
			// color: Colors.lightBlueAccent,
			child: ListTile (
				title: Text (
					period == null
						? "School is over"
						: "Current class: ${subject?.name ?? period.period}.",
					textScaleFactor: 1.5,
					// style: TextStyle (color: Colors.)
				),
				leading: Icon (Icons.school, size: 35),// color: Colors.black),
				subtitle: Column (
					crossAxisAlignment: CrossAxisAlignment.start,
					children: (period?.getInfo() ?? []).map (
						(String description) => Padding (
							padding: EdgeInsets.symmetric (vertical: 5),
							child: Text (
								description,
								textScaleFactor: 1.25,
								// style: white
							)
						)
					).toList()
				)
			)
		);
	}
}

class ClassList extends StatelessWidget {
	final Iterable<Period> periods;
	const ClassList (this.periods);

	@override Widget build (BuildContext context) => ListView (
		children: <Widget>[
			DrawerHeader (
				child: Center (
					child: Text (
						"Upcoming classes",
						textScaleFactor: 2
					)
				)
			)
		] + periods.map (
			(Period period) {
				final Subject subject = getSubject (period);
				final List<String> info = period.getInfo();
				// ListTile has the period number, so get rid of it
				info.removeWhere(
					(String description) => description.startsWith("Period:")
				);
				return InfoCard (
					title: "${period.period}${subject == null ? '' : ': ${subject.name}'}",
					children: info.map (
						(String description) => Text (description)
					).toList()
				);
			}
		).toList()
	);
}

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

class SchedulePage extends StatefulWidget {
	final Student student;

	SchedulePage (this.student);

	@override HomePageState createState() => HomePageState();
}

class HomePageState extends State <SchedulePage> {
	Day today = getToday();
	Schedule schedule;
	Period currentPeriod;
	Subject currentSubject;

	static Duration minute = Duration (minutes: 1);
	Timer timer;

	String special;
	List <Period> periods;
	int periodNumber;

	@override void initState () {
		super.initState();
		timer = Timer.periodic (minute, updateScreen);
		schedule = widget.student.schedule [today.letter];
		periods = widget.student.getPeriods (today);
		periodNumber = today.period;
		currentPeriod = periodNumber == null 
			? null
			: periods [periodNumber];
		currentSubject = getSubject (currentPeriod);
	}

	@override void dispose() {
		timer.cancel();
		super.dispose();
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
								: "Current class: ${currentSubject?.name ?? currentPeriod.period}",
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
					icon: Icons.fastfood,
					padding: 5,
					children: [
						Text ("Main: ${today.lunch.main}"),
						Text ("Soup: ${today.lunch.soup}"),
						Text ("Side 1: ${today.lunch.side1}"),
						Text ("Side 2: ${today.lunch.side2}"),
						Text ("Salad: ${today.lunch.salad}"),
						Text ("Dessert: ${today.lunch.dessert}")
					],
				)),

				DropdownButton<Letters> (
					onChanged: (Letters letter) => setState (() {
						today = Day (
							letter: letter, 
							lunch: today.lunch
						);
						periods = widget.student.getPeriods(today);
					}),
					value: today.letter,
					hint: Text ("Choose letter"),
					items: <DropdownMenuItem<Letters>> [
						DropdownMenuItem (
							child: Text ("M"),
							value: Letters.M
						),
						DropdownMenuItem (
							child: Text ("R"),
							value: Letters.R
						),
						DropdownMenuItem (
							child: Text ("A"),
							value: Letters.A
						),
						DropdownMenuItem (
							child: Text ("B"),
							value: Letters.B
						),
						DropdownMenuItem (
							child: Text ("C"),
							value: Letters.C
						),
						DropdownMenuItem (
							child: Text ("E"),
							value: Letters.E
						),
						DropdownMenuItem (
							child: Text ("F"),
							value: Letters.F
						)
					]
				)
			]
		),
	);

	updateScreen(_) {
		setState(() {
			periodNumber = today.period;
		});
	}
}
