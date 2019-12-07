import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";

import "info_card.dart";
import "reminder_tile.dart";

class NextClass extends StatelessWidget {
	static const TextStyle white = TextStyle (color: Colors.white);
	static const double reminderPadding = 10;

	final bool modified, next;
	final Period period;
	final Subject subject;
	final List<int> reminders;

	const NextClass({
		@required this.period,
		@required this.subject,
		@required this.reminders,
		@required this.modified,
		this.next = false,
	});

	@override 
	Widget build (BuildContext context) => Column(
		children: [
			InfoCard (
				icon: next ? Icons.restore : Icons.school,
				children: modified 
					? const ["See side panel or click for schedule"] 
					: period?.getInfo(subject),
				page: Routes.schedule,
				title: modified ? "Times unavailable" : 
					period == null
					? "School is over"
					: "${next ? 'Next' : 'Current'} period: " 
						"${subject?.name ?? period.period}",
			),

			for (final int index in reminders) Padding (
				padding: const EdgeInsets.symmetric(horizontal: reminderPadding),
				child: Container (
					foregroundDecoration: ShapeDecoration(
						shape: RoundedRectangleBorder(
							side: BorderSide(color: Theme.of(context).primaryColor),
							borderRadius: BorderRadius.circular (20),
						)
					),
					child: ReminderTile(index: index),
				)
			)
		]
	);
}
