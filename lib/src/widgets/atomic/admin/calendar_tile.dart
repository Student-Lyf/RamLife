import "package:flutter/material.dart";

import "package:ramaz/data.dart";

/// A cell in a calendar that represents a [Day].
/// 
/// This widget is to be used in the admin view of the calendar. Tapping it 
/// will allow the admin to change the day in the database. 
class CalendarTile extends StatelessWidget{
	/// The date for this tile. 
	final int date;
	
	/// The [Day] represented by this tile. 
	final Day day;

	/// Creates a widget to update a day in the calendar
	const CalendarTile({
		@required this.date,
		@required this.day,
	});

	@override
	Widget build(BuildContext context) => Container(
		decoration: BoxDecoration(border: Border.all()),
		child: Stack (
			children: [
				if (day != null) ...[ 
					Align (
						alignment: Alignment.topLeft,
						child: Text ((date + 1).toString()),
					),
					if (day?.letter != null)
						Center (
							child: Text (
								lettersToString [day.letter], 
								textScaleFactor: 1.5
							),
						),
					if (
						day?.letter != null &&
						!<String>[Special.rotate.name, Special.regular.name]
							.contains(day.special?.name)
					) Align(
						alignment: Alignment.bottomCenter,
						child: const Text ("•", textScaleFactor: 0.8),
					)
				]
			]
		)
	);
}
