import "package:flutter/material.dart";
import "package:link_text/link_text.dart";

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
	/// This list holds the indices of the reminders for this period in 
	/// [Reminders.reminders].
	final List<int> reminders;

	/// An activity for this period. 
	final Activity? activity;

	/// Creates a widget to represent a period. 
	const ClassPanel ({
		required this.title,
		required this.children,
		required this.reminders,
		this.activity,
	});

	@override 
	Widget build (BuildContext context) => ExpansionTile (
		title: SizedBox (
			height: 50,
			child: Center (
				child: ListTile (
					title: Text (title),
					contentPadding: EdgeInsets.zero,
					trailing: reminders.isEmpty ? null : const Icon(Icons.note),
					leading: activity == null ? null : const Icon(Icons.announcement),
				),
			),
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
									child: LinkText(
										label, 
										shouldTrimParams: true,
										linkStyle: const TextStyle(color: Color(0xff0000EE)),
									),
								),
							if (activity != null)
								ActivityTile(activity!),  // already checked for null
							for (final int index in reminders)
								ReminderTile (
									index: index,
									height: 60,
								),
						],
					),
				),
			),
		],
	);
}

/// A list of all the classes for a given day.
/// 
/// The list is composed of [ClassPanel]s, one for each period in the day. 
class ClassList extends StatefulWidget {
	/// The day whose periods should be represented.
	final Day day;

	/// A list of periods for today. 
	/// 
	/// Comes from using [day] with [User.getPeriods].
	final Iterable<Period> periods;

	/// The header for this list. May be null.
	final String? headerText;

	/// Creates a list of [ClassPanel] widgets to represent periods in a day.
	const ClassList({
		required this.day, 
		required this.periods,
		this.headerText,
	});

	/// Populates fields from the given model.
	ClassList.fromSchedule(ScheduleModel model) : 
		day = model.today!,
		periods = model.nextPeriod == null 
			? model.periods!
			: model.periods!.getRange (
				(model.periodIndex ?? -1) + 1, 
				model.periods!.length,
			),
			headerText = model.period == null 
				? "Today's Schedule" 
				: "Upcoming Classes";

	@override
	ClassListState createState() => ClassListState();
}

/// A state for the class list. 
class ClassListState extends ModelListener<Reminders, ClassList> {
	/// Creates a state that can read reminders
	ClassListState() : super(shouldDispose: false);

	@override 
	Reminders getModel() => Models.instance.reminders;

	@override 
	Widget build(BuildContext context) => ListView(
		shrinkWrap: true,
		children: [
			if (widget.headerText != null) DrawerHeader(
				child: Center (
					child: Text (
						widget.headerText ?? "",
						textScaleFactor: 2,
						textAlign: TextAlign.center,
					),
				),
			),  
			...[
				for (final Period period in widget.periods) 
					getPanel(period),
			],
		],
	);

	/// Creates a [ClassPanel] for a given period. 
	Widget getPanel(Period period) {
		final subject = Models.instance.schedule.subjects[period.id];
		return ClassPanel (
			children: [
				for (final String description in period.getInfo(subject))
					if (!description.startsWith("Period:"))
						description,
				if (period.id != null) 
					"ID: ${period.id}",
			],
			title: int.tryParse(period.name) == null 
				? period.getName(subject)
				: "${period.name}: ${period.getName(subject)}",
			reminders: Models.instance.reminders.getReminders(
				period: period.name,
				dayName: widget.day.name,
				subject: subject?.name,
			),
			activity: period.activity,
		);
	}
}
