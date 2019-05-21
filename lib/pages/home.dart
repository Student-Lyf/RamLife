import "package:flutter/material.dart";
import "dart:async";

// Backend tools
import "package:ramaz/data/schedule.dart";

// Dataclasses
import "package:ramaz/services/reader.dart";
import "package:ramaz/services/auth.dart" as Auth;
import "package:ramaz/services/preferences.dart";

// UI
import "package:ramaz/pages/drawer.dart";
import "package:ramaz/widgets/class_list.dart";
import "package:ramaz/widgets/next_class.dart";
import "package:ramaz/widgets/date_picker.dart" show pickDate;
// import "package:ramaz/widgets/lunch.dart";
import "package:ramaz/widgets/icons.dart";

class HomePage extends StatefulWidget {
	final Reader reader;
	final Preferences prefs;
	HomePage ({
		@required this.reader,
		@required this.prefs
	});

	@override HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	static const Duration minute = Duration (minutes: 1);

	final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
	final GlobalKey<DrawerState> drawerKey = GlobalKey();
	Timer timer;

	Period period, nextPeriod;
	Schedule schedule;
	Day today;
	DateTime selectedDay;
	List<Period> periods;
	int periodIndex;
	bool needsGoogleSignIn = false, school; 

	@override void initState() {
		super.initState();
		if (widget.reader.currentDay != null)
			today = widget.reader.currentDay;
		else today = widget.reader.today;
		selectedDay = DateTime.now();
		widget.reader.currentDay = today;
		school = today.letter != null;
		Auth.needsGoogleSupport().then (
			(bool value) => setState(
				() => needsGoogleSignIn = value
			)
		);
		timer = Timer.periodic (minute, update);
		schedule = widget.reader.student.schedule [today.letter];
		periods = widget.reader.student.getPeriods (today);
		update();
	}

	@override void dispose() {
		timer.cancel();
		super.dispose();
	}

	@override Widget build (BuildContext context) => Scaffold (
		key: scaffoldKey,
		appBar: AppBar (
			title: Text ("Home"),
			actions: [
				if (needsGoogleSignIn) IconButton (
					icon: Logos.google,
					onPressed: addGoogleSignIn,
				),
				if (school) FlatButton (
					child: Text ("Swipe left for schedule"),
					textColor: Colors.white,
					onPressed: () => scaffoldKey.currentState.openEndDrawer()
				)
			],
		),
		drawer: NavigationDrawer(widget.prefs, key: drawerKey),
		endDrawer: !school ? null : Drawer (
			child: ClassList(
				periods: nextPeriod == null 
					? periods
					: periods.getRange (
						(periodIndex ?? -1) + 1, periods.length
					),
				reader: widget.reader,
				headerText: period == null 
					? "Today's Schedule" 
					: "Upcoming Classes"
			)
		),
		floatingActionButton: FloatingActionButton (
			child: Icon (Icons.calendar_today),
			onPressed: viewDay
		),
		body: RefreshIndicator (  // so you can refresh the period
			onRefresh: () async => update(),
			child: ListView (
				children: [
					RamazLogos.ram_rectangle,
					Divider(),
					Text (
						school
							? "Today is a${today.n} ${today.name}"
							: "There is no school today",
						textScaleFactor: 2,
						textAlign: TextAlign.center
					),
					SizedBox (height: 20),
					if (school)
						NextClass(period, widget.reader.subjects[period?.id]),
					if (nextPeriod != null)  // if school is not over, show the next class
						NextClass (
							nextPeriod, 
							widget.reader.subjects[nextPeriod?.id], 
							next: true
						),
					// LunchTile (lunch: today.lunch),
				]
			)
		)
	);

	void update([_]) => setState(() {
		if (!school) {
			nextPeriod = null;
			return;
		}
		periodIndex = today.period;
		// print (periodIndex);
		period = periodIndex == null ? null : periods [periodIndex];	
		if (periodIndex != null && periodIndex < periods.length - 1)
			nextPeriod = periods [periodIndex + 1];
		else nextPeriod = null;
	});

	void addGoogleSignIn() async {
		final account = await Auth.signInWithGoogle(
			() => scaffoldKey.currentState.showSnackBar(
				SnackBar (
					content: Text ("You need to sign in with your Ramaz email")
				)
			),
			link: true
		);
		if (account == null) return;
		else showDialog (
			context: context,
			builder: (BuildContext context) => AlertDialog(
				title: Text ("Google sign in enabled"),
				content: ListTile (
					title: Text (
						"You can now sign in with your Google account"
					)
				),
				actions: [
					FlatButton (
						child: Text ("OK"),
						onPressed: () {
							setState(() => needsGoogleSignIn = false);
							Navigator.of(context).pop();
						}
					)
				]
			)
		);
	}

	set day (DateTime date) {
		DateTime day = DateTime.utc(
			date.year, 
			date.month, 
			date.day
		);
		today = widget.reader.calendar [day];
		widget.reader.currentDay = today;
		periods = widget.reader.student.getPeriods(today);
		school = today.letter != null;
		update();
	}

	void viewDay() async {
		final DateTime selected = await pickDate (
			context: context,
			initialDate: selectedDay
		);	
		if (selected == null) return;
		selectedDay = selected;
		day = selected;
	}
}
