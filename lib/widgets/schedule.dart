// TODO: refresh every minute
// VERIFY: Today is a(n) message (see comment)
// VERIFY: How many periods are left in the dropdown
// VERIFY: Times

import "package:flutter/material.dart";

import "../backend/times.dart";
import "../backend/data/schedule.dart";
import "../backend/data/student.dart";
import "../constants.dart" show SCHEDULE;

import "drawer.dart";
import "info_card.dart";


class NextClass extends StatelessWidget {
	final Period period;
	const NextClass(this.period);
	static final TextStyle white = TextStyle (
		color: Colors.white
	);

	@override Widget build (BuildContext context) {
		final Subject subject = period.subject;
		return InfoCard (
			icon: Icons.school,
			title: period == null
				? "School is over"
				: "Current class: ${subject?.name ?? period.period}",
			children: period?.getInfo(),
			page: SCHEDULE
		);
	}
}

class ClassList extends StatelessWidget {
	final Iterable<Period> periods;
	final String headerText;
	const ClassList ({@required this.periods, this.headerText});

	@override Widget build (BuildContext context) => ListView (
		shrinkWrap: true,
		children: 
			(headerText == null 
					? const <Widget> [] 
					: <Widget>[
						DrawerHeader (
							child: Center (
								child: Text (
									headerText,
									textScaleFactor: 2
								)
							)
						)
					]
			) + periods.map (
			(Period period) {
				final Subject subject = period.subject;
				final List<String> info = period.getInfo();
				// ListTile has the period number, so get rid of it
				info.removeWhere(
					(String description) => description.startsWith("Period:")
				);
				return ClassPanel (
					title: "${period.period}${subject == null ? '' : ': ${subject.name}'}",
					children: info.map (
						(String description) => Text (description)
					).toList(),
				);
			}
		).toList()
	);
}

class ClassPanel extends StatelessWidget {
	final String title;
	final List <Widget> children;

	const ClassPanel ({
		@required this.title,
		@required this.children,
	});

	@override Widget build (BuildContext context) => ExpansionTile (
		title: Text(title),
		children: [Align (
			alignment: const Alignment (-0.75, 0),
			child: Column (
				crossAxisAlignment: CrossAxisAlignment.start,
				children: children.map (
					(Widget child) => Padding (
						padding: const EdgeInsets.symmetric(vertical: 5),
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

class ScheduleState extends State<SchedulePage> {
	static const Letters defaultLetter = Letters.M;
	static final Special defaultSpecial = regular;

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

	void update({Letters newLetter, Special newSpecial}) {
		print ("letter: $newLetter, special: ${newSpecial?.name}");
		if (newLetter != null) {
			this.letter = newLetter;
			switch (newLetter) {
				case Letters.A: 
				case Letters.B:
				case Letters.C: 
					special = rotate;
					break;
				case Letters.M:
				case Letters.R: 
					special = regular;
					break;
				case Letters.E:
				case Letters.F:
					special = Special.getWinterFriday();
			}
		}
		if (newSpecial != null) {
			final List<Special> fridays = [
				friday, 
				winterFriday, 
				fridayRoshChodesh, 
				winterFridayRoshChodesh
			];
			switch (letter) {
				case Letters.A:
				case Letters.B:
				case Letters.C:
				case Letters.M:
				case Letters.R:
					if (!fridays.contains (newSpecial)) 
						special = newSpecial;
					break;
				case Letters.E:
				case Letters.F:
					if (fridays.contains (newSpecial))
						special = newSpecial;
			}
		}
		setState(() {
			schedule = widget.student.schedule [letter];
			day = getDay (letter, special);
			periods = widget.student.getPeriods (day);
		});
	}

	@override
	Widget build (BuildContext context) => Scaffold (
		appBar: AppBar (title: Text ("Schedule")),
		drawer: NavigationDrawer(),
		body: Column (
			children: [
				ListTile (
					title: Text ("Choose a letter"),
					trailing: DropdownButton<Letters> (
						value: letter, 
						onChanged: (Letters letter) => update (newLetter: letter),
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
						onChanged: (Special special) => update (newSpecial: special),
						items: specials.map<DropdownMenuItem<Special>> (
							(Special special) => DropdownMenuItem<Special> (
								child: Text (special.name),
								value: special
							)
						).toList()
					)
				),
				SizedBox (height: 20),
				Divider(),
				SizedBox (height: 20),
				Expanded (child: ClassList(periods: periods))
			]
		)
	);
}
