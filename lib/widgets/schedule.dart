// TODO: refresh every minute
// VERIFY: Today is a(n) message (see comment)
// VERIFY: How many periods are left in the dropdown
// VERIFY: Times

import "package:flutter/material.dart";

import "../backend/times.dart" show Special, specials;
import "../backend/schedule.dart";
import "../backend/student.dart";
import "../backend/helpers.dart";

import "drawer.dart";
import "info_tile.dart";


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
		return InfoTile (
			icon: Icons.school,
			title: period == null
				? "School is over"
				: "Current class: ${subject?.name ?? period.period}",
			children: period?.getInfo()
		);
	}
}

class ClassList extends StatelessWidget {
	final Iterable<Period> periods;
	final String headerText;
	const ClassList ({@required this.periods, @required this.headerText});

	@override Widget build (BuildContext context) => ListView (
		shrinkWrap: true,
		children: <Widget>[DrawerHeader (
			child: Center (
				child: Text (
					headerText,
					textScaleFactor: 2
				)
			)
		)] + periods.map (
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
					).toList(),
				);
			}
		).toList()
	);
}

class InfoCard extends StatelessWidget {
	final String title;
	// final IconData icon;
	final List <Widget> children;
	// final double padding;

	const InfoCard ({
		@required this.title,
		@required this.children,
	});

	@override Widget build (BuildContext context) => ExpansionTile (
		title: Text(title),
		children: [Align (
			alignment: Alignment (-0.75, 0),
			child: Column (
				crossAxisAlignment: CrossAxisAlignment.start,
				children: children.map (
					(Widget child) => Padding (
						padding: EdgeInsets.symmetric(vertical: 5),
						child: child
					) 
				).toList()
			)
		)]
	);
}

class SchedulePage extends StatefulWidget {
	final Student student;
	SchedulePage (this.student);

	@override ScheduleState createState() => ScheduleState();
}

class ScheduleState extends State <SchedulePage> {
	static const Letters defaultLetter = Letters.M;
	static final Special defaultSpecial = specials [0];

	Letters letter = defaultLetter;
	Special special = defaultSpecial;
	Day day = getDay (defaultLetter, defaultSpecial);
	Schedule schedule;
	List<Period> periods;

	static Day getDay (Letters letter, Special special) => Day (
		letter: letter,
		special: special,
		lunch : null
	);

	@override void initState () {
		super.initState();
		update();
	}

	void update({Letters letter, Special special}) {
		if (letter != null) this.letter = letter;
		if (special != null) this.special = special;
		schedule = widget.student.schedule [letter];
		periods = widget.student.getPeriods (day);
	}

	@override
	Widget build (BuildContext context) => Scaffold (
		appBar: AppBar (title: Text ("Schedule")),
		drawer: NavigationDrawer(),
		body: ListView (
			children: [
				ListTile (
					title: Text ("Choose a letter"),
					trailing: DropdownButton<Letters> (
						value: letter, 
						onChanged: (Letters letter) => update (letter: letter),
						items: Letters.values.map<DropdownMenuItem<Letters>> (
							(Letters letter) => DropdownMenuItem<Letters> (
								child: Text (letter.toString().split(".").last),
								value: letter
							)
						).toList()
					)
				),
				ListTile (
					title: Text ("Choose a schedule"),
					trailing: DropdownButton<Special> (
						value: special,
						onChanged: (Special special) => update (special: special),
						items: specials.map<DropdownMenuItem<Special>> (
							(Special special) => DropdownMenuItem<Special> (
								child: Text (special.name),
								value: special
							)
						).toList()
					)
				)
			]
		)
	);
}
