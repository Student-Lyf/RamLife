import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

import "info_card.dart";
import "reminder_tile.dart";

/// A decorative border around a special addition to [NextClass]. 
class SpecialTile extends StatelessWidget {
	/// The widget to go inside the border. 
	final Widget child;

	/// Creates a decorative border. 
	const SpecialTile({required this.child});

	@override
	Widget build (BuildContext context) => Padding (
		padding: const EdgeInsets.symmetric(horizontal: 10),
		child: Container (
			foregroundDecoration: ShapeDecoration(
				shape: RoundedRectangleBorder(
					side: BorderSide(color: Theme.of(context).primaryColor),
					borderRadius: BorderRadius.circular(20),
				)
			),
			child: child,
		)
	);
}

/// A widget to represent the next class. 
class NextClass extends StatelessWidget {
	/// Whether this is the next period or not.
	/// 
	/// This changes the text from "Right now" to "Up next". 
	final bool next;

	/// The period to represent. 
	final Period? period;

	/// The subject associated with [period]. 
	final Subject? subject;

	/// The reminders that apply for this period. 
	/// 
	/// These are indices in the reminders data model.
	final List<int> reminders;

	/// Creates an info tile to represent a period. 
	const NextClass({
		required this.reminders,
		this.period,
		this.subject,
		this.next = false,
	});

	@override 
	Widget build (BuildContext context) => Column(
		children: [
			InfoCard(
				icon: next ? Icons.restore : Icons.school,
				children: period?.getInfo(subject),
				page: Routes.schedule,
				title: period == null
					? "School is over"
					: "${next ? 'Up next' : 'Right now'}: ${period!.getName(subject)}"
			),
			if (period?.activity != null) 
				SpecialTile(child: ActivityTile(period!.activity!)),
			for (final int index in reminders) 
				SpecialTile(child: ReminderTile(index: index))
		]
	);
}
