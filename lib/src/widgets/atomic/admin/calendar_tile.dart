import "package:flutter/material.dart";

import "package:ramaz/data.dart";

/// A cell in a calendar that represents a [Day].
/// 
/// This widget is to be used in the admin view of the calendar. Tapping it 
/// will allow the admin to change the day in the database. 
class CalendarTile extends StatelessWidget{
	/// A blank calendar tile. 
	/// 
	/// This should not be wrapped in a [GestureDetector]. 
	static const CalendarTile blank = CalendarTile(day: null, date: null);

	/// The [Day] this cell represents. 
	final Day? day;

	/// The date this cell represents.
	final DateTime? date;

	/// Creates a widget to update a day in the calendar
	const CalendarTile({required this.day, required this.date});

	@override
	Widget build(BuildContext context) => Container(
		decoration: BoxDecoration(border: Border.all()),
		child: date == null ? Container() : LayoutBuilder(
			builder: (BuildContext context, BoxConstraints constraints) {
				final double textSize = constraints.biggest.width > 120 ? 1.5 : 1;
				return Column(
					children: [
						Align (
							alignment: Alignment.topLeft,
							child: Text (date!.day.toString(), textScaleFactor: 1),
						),
						const Spacer(),
						if (day == null) 
							Expanded(child: Text("No school", textScaleFactor: textSize))
						else ...[
							Expanded(child: Text (day!.name, textScaleFactor: textSize)),
							Expanded(child: Text (day!.schedule.name, textScaleFactor: 0.8)),
						],
						const Spacer(),
					]
				);
			}
		)
	);
}
