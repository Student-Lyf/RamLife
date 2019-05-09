import "package:flutter/material.dart";

import "package:ramaz/data/times.dart";
import "package:ramaz/data/schedule.dart";

import "package:ramaz/services/reader.dart";

import "package:ramaz/pages/drawer.dart";
import "package:ramaz/widgets/class_list.dart";

class SchedulePage extends StatefulWidget {
	final Reader reader;
	final bool canExit;
	SchedulePage (this.reader, {this.canExit = false});

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
			schedule = widget.reader.student.schedule [letter];
			day = getDay (letter, special);
			periods = widget.reader.student.getPeriods (day);
		});
	}

	@override
	Widget build (BuildContext context) => Scaffold (
		appBar: AppBar (
			title: Text ("Schedule"),
			actions: [
				IconButton (
					icon: Icon (Icons.home),
					onPressed: () {
						final NavigatorState nav = Navigator.of(context);
						if(nav.canPop()) nav.pop();  // if pressed on home screen
						nav.pushReplacementNamed("home");
					}
				)
			]
		),
		drawer: widget.canExit ? null : NavigationDrawer(),
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
				Expanded (child: ClassList(periods: periods, reader: widget.reader))
			]
		)
	);
}
