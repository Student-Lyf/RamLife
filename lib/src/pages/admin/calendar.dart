import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A widget to represent a calendar icon.
/// 
/// Due to "budget cuts", poor Levi Lesches ('21) had to recreate the calendar 
/// icon from scratch, instead of Googling for a png. What a loser. 
/// 
/// This widget is not used, rather left here as a token of appreciation for
/// all the time Levi has wasted designing (and scrapping said designs)
/// the UI and backend code for this app. That dude deserves a raise.
class OldCalendarWidget extends StatelessWidget {
	/// Creates a widget to look like the calendar icon. 
	const OldCalendarWidget();

  @override
  Widget build(BuildContext context) => InkWell(
  	onTap: () => Navigator.pushReplacementNamed(context, Routes.calendar),
  	child: Container(
	    decoration: BoxDecoration(border: Border.all()),
	    padding: const EdgeInsets.symmetric(horizontal: 25),
	    child: Column(
	      mainAxisAlignment: MainAxisAlignment.center,
	      crossAxisAlignment: CrossAxisAlignment.center,
	      children: [
	        const Spacer(flex: 1),
	        Expanded(
	          flex: 1,
	          child: Container(
	            decoration: BoxDecoration(border: Border.all()),
	            child: const Center(
	              child: Text("Monday")
	            ),
	          ),
	        ),
	        Expanded(
	          flex: 4,
	          child: Container(
	            decoration: BoxDecoration(border: Border.all()),
	            child: const Center(
	              child: Text("01", textScaleFactor: 2),
	            )
	          )
	        ),
	        const Spacer(flex: 1),
	      ]
	    )
    )
  );
}

/// A page for admins to modify the calendar in the database. 
class AdminCalendarPage extends StatefulWidget {
	/// Creates a page to edit the calendar.
	const AdminCalendarPage();

	@override
	AdminCalendarState createState() => AdminCalendarState();
}

/// The state for the admin calendar page. 
class AdminCalendarState extends ModelListener<
	CalendarEditor, AdminCalendarPage
> {
	/// The months of the year. 
	/// 
	/// These will be the headers of all the months. 
	static const List<String> months = [
		"January", "February", "March", "April", "May", 
		"June", "July", "August", "September", "October",
		"November", "December"
	];

	/// The days of the week. 
	/// 
	/// This will be used as the labels of the calendar. 
	static const List<String> weekdays = [
		"Sun", "Mon", "Tue", "Wed", "Thur", "Fri", "Sat"
	];

	@override
	CalendarEditor getModel() => CalendarEditor();

	int _currentMonth = DateTime.now().month - 1;
	
	/// The current month being viewed. 
	/// 
	/// Changing this will load the month from the database if needed.
	int get currentMonth => _currentMonth;
	set currentMonth(int value) {
		_currentMonth = loopMonth(value);
		model.loadMonth(_currentMonth);  // will update later
		setState(() {});
	}

	/// Allows the user to go from Dec to Jan and vice-versa.
	int loopMonth(int val) {
		if (val == 12) {
			return 0;
		} else if (val == -1) {
			return 11;
		} else {
			return val;
		}
	}

	@override
	Widget build(BuildContext context) => ResponsiveScaffold(
		drawer: const NavigationDrawer(),
		appBar: AppBar(title: const Text("Calendar")),
		bodyBuilder: (_) => Center(
			child: Column(
				mainAxisSize: MainAxisSize.min,
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					const SizedBox(height: 24),
					Row(
						children: [
							const Spacer(flex: 3),
							TextButton.icon(
								icon: const Icon(Icons.arrow_back),
								onPressed: () => currentMonth--,
								label: Text(months [loopMonth(currentMonth - 1)]),
							),
							const Spacer(flex: 2),
							Text(
								"${months [currentMonth]} ${model.years [currentMonth]}",
								style: Theme.of(context).textTheme.headline4,
							),
							const Spacer(flex: 2),
							TextButton.icon(
								// icon always goes to the left of the label
								// since they're both widgets, we can swap them
								label: const Icon(Icons.arrow_forward),
								icon: Text(months [loopMonth(currentMonth + 1)]),
								onPressed: () => currentMonth++,
							),
							const Spacer(flex: 3),
						]
					),
					const SizedBox(height: 16),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceEvenly,
						children: [
							for (final String weekday in weekdays)
								Text(weekday),
						]
					),
					Flexible(
						child: model.calendar [currentMonth] == null
							? const Center(child: CircularProgressIndicator())
							: GridView.count(
								padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
								shrinkWrap: true,
								childAspectRatio: 1.25,
								crossAxisCount: 7,
								children: [
									for (final CalendarDay? day in model.calendar [currentMonth]!)
										if (day == null) CalendarTile.blank
										else GestureDetector(
											onTap: () => showDialog(
												context: context,
												builder: (_) => DayBuilder(
													day: day.schoolDay, 
													date: day.date,
													upload: (Day? value) => model.updateDay(
														day: value, 
														date: day.date
													),
												)
											),
											child: CalendarTile(day: day.schoolDay, date: day.date),
										)
								]
							),
					)
				]
			)
		)
	);
}
