import "package:flutter/material.dart";

import "package:ramaz/data/times.dart";
import "package:ramaz/data/schedule.dart";

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/preferences.dart";

import "package:ramaz/pages/drawer.dart";
import "package:ramaz/widgets/class_list.dart";
import "package:ramaz/widgets/date_picker.dart" show pickDate;

class SchedulePage extends StatefulWidget {
	final Reader reader;
	final Preferences prefs;
	final bool canExit;
	SchedulePage ({
		@required this.prefs,
		@required this.reader,
		this.canExit = false,
	});

	@override ScheduleState createState() => ScheduleState();
}

class ScheduleState extends State<SchedulePage> {
	static const Letters defaultLetter = Letters.M;
	static final Special defaultSpecial = regular;

	final GlobalKey<ScaffoldState> key = GlobalKey();

	Day day;
	Letters letter;
	Special special;
	Schedule schedule;
	DateTime selectedDay = DateTime.now();
	List<Period> periods;
	Map<DateTime, Day> calendar;

	static Day getDay (Letters letter, Special special) => Day (
		letter: letter,
		special: special,
		lunch : null
	);

	@override void initState () {
		super.initState();
		final Day readerDay = widget.reader.currentDay;
		if (readerDay == null || readerDay.letter == null) 
			day = getDay (defaultLetter, defaultSpecial);
		else day = readerDay;
		letter = day.letter;
		special = day.special;

		try {date = DateTime.now();}
		on ArgumentError {}
		update();
	}

	set date (DateTime date) {
		final DateTime dateTime = DateTime.utc(
			date.year, 
			date.month, 
			date.day
		);
		final Day selected = widget.reader.calendar [dateTime];
		if (selected.letter == null) throw ArgumentError();
		widget.reader.currentDay = selected;
		update(
			newLetter: selected.letter, 
			newSpecial: selected.special
		);
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

	void viewDay() async {
		final DateTime selected = await pickDate (
			context: context,
			initialDate: selectedDay
		);
		if (selected == null) return;
		selectedDay = selected;
		try {date = selected;}
		on ArgumentError {
			key.currentState.showSnackBar(
				SnackBar (
					content: Text ("There is no school on this day")
				)
			);
		}
	}

	@override
	Widget build (BuildContext context) => Scaffold (
		key: key,
		appBar: AppBar (
			title: Text ("Schedule"),
			actions: widget.canExit ? null : [
				IconButton (
					icon: Icon (Icons.calendar_today),
					onPressed: viewDay
				),
				IconButton (
					icon: Icon (Icons.home),
					onPressed: () => Navigator
						.of(context)
						.pushReplacementNamed("home")
				)
			]
		),
		drawer: widget.canExit ? null : NavigationDrawer(widget.prefs),
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
