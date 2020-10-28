import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// An [ExpansionTile] for an individual period in a list. 
class ClassPanel extends StatelessWidget {
	/// The title for this panel. 
	/// 
	/// It should be the name of the period (usually a number). 
	final String title;

	/// A list of descriptive strings about the period.
	/// 
	/// Can include the time, room, or teacher of the period. Really any property
	/// of [Period] is good.
	final List<String> children;

	/// A list of reminders for this period. 
	/// 
	/// This list holds th indices of the reminders for this period in 
	/// [Reminders.reminders].
	final List<int> reminders;

	/// An activity for this period. 
	final Activity activity;

	/// Creates a widget to represent a period. 
	const ClassPanel ({
		@required this.title,
		@required this.children,
		@required this.reminders,
		@required this.activity,
	});

	@override Widget build (BuildContext context) => ExpansionTile (
		title: SizedBox (
			height: 50,
			child: Center (
				child: ListTile (
					title: Text (title),
					contentPadding: EdgeInsets.zero,
					trailing: reminders.isEmpty ? null : const Icon(Icons.note),
					leading: activity == null ? null : const Icon(Icons.announcement),
				)
			)
		),
		children: [
			Padding (
				padding: const EdgeInsets.only(left: 30),
				child: Align (
					alignment: Alignment.centerLeft,					
					child: Column (
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							for (final String label in children) 
								Padding (
									padding: const EdgeInsets.symmetric(vertical: 5),
									child: Text (label)
								),
							if (activity != null)
								ActivityTile(activity),
							for (final int index in reminders)
								ReminderTile (
									index: index,
									height: 60,
								)
						]
					)
				)
			)
		]
	);
}

/// A list of all the classes for a given day.
/// 
/// The list is composed of [ClassPanel]s, one for each period in the day. 
class ClassList extends StatelessWidget {
	/// The day whose periods should be represented.
	final Day day;

	/// A list of periods for today. 
	/// 
	/// Comes from using [day] with [User.getPeriods].
	final Iterable<Period> periods;

	/// The header for this list. May be null.
	final String headerText;

	/// Creates a list of [ClassPanel] widgets to represent periods in a day.
	const ClassList ({
		@required this.day, 
		this.headerText,
		this.periods,
	});

	Iterable<Period> _getPeriods(BuildContext context) {
		try {
			return periods ?? Models.instance.schedule.user.getPeriods(day);
		} on RangeError { // ignore: avoid_catching_errors
			Future(  // cannot show snackbar on build, so wait for next frame
				() => Scaffold.of(context).showSnackBar(
					const SnackBar(content: Text("Invalid schedule"))
				)
			);
			return Models.instance.schedule.user.getPeriods(
				Models.instance.schedule.today
			);
		}
	}

	@override Widget build(BuildContext context) => ModelListener<Reminders>(
		model: () => Models.instance.reminders,
		dispose: false,
		// ignore: sort_child_properties_last
		child: DrawerHeader (
			child: Center (
				child: Text (
					headerText ?? "",
					textScaleFactor: 2,
					textAlign: TextAlign.center,
				)
			)
		),
		builder: (_, __, Widget header) => ListView(
			shrinkWrap: true,
			children: [
				if (headerText != null) header,
				...[
					for (final Period period in _getPeriods(context)) 
						getPanel(period)
				],
			]
		)
	);

	/// Creates a [ClassPanel] for a given period. 
	Widget getPanel(Period period) {
		final Subject subject = Models.instance.schedule.subjects[period.id];
		return ClassPanel (
			children: [
				for (final String description in period.getInfo(subject))
					if (!description.startsWith("Period:"))
						description,
				if (period.id != null) 
					"ID: ${period.id}",
			],
			title: int.tryParse(period.period) == null 
				? period.getName(subject)
				: "${period.period}: ${period.getName(subject)}",
			reminders: Models.instance.reminders.getReminders(
				period: period.period,
				dayName: day.name,
				subject: subject?.name,
			),
			activity: period?.activity,
		);
	}
}
