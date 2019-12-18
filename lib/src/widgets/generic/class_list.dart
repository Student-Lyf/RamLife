import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

class ClassPanel extends StatelessWidget {
	final String title;
	final List<String> children;
	final List<int> reminders;
	final Activity activity;

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
					trailing: reminders.isEmpty ? null : Icon(Icons.note),
					leading: activity == null ? null : Icon(Icons.error),
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

class ClassList extends StatelessWidget {
	final Day day;
	final Iterable<Period> periods;

	final String headerText;

	const ClassList ({
		@required this.day, 
		this.headerText,
		this.periods,
	});

	@override Widget build(BuildContext context) => ModelListener<Reminders>(
		model: () => Services.of(context).reminders,
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
		builder: (BuildContext context, Reminders reminders, Widget header) {
			final Services services = Services.of(context);
			return ListView (
				shrinkWrap: true,
				children: [
					if (headerText != null) header,
					...[
						for (
							final Period period in 
							periods ?? services.schedule.student.getPeriods(day)
						) getPanel(services, period)
					],
				]
			);
		}
	);

	Widget getPanel(Services services, Period period) {
		final Subject subject = services.schedule.subjects[period.id];
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
			reminders: services.reminders.getReminders(
				period: period.period,
				letter: day.letter,
				subject: subject?.name,
			),
			activity: period.activity,
		);
	}
}
