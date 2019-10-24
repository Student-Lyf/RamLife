import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

import "../ambient/services.dart";
import "../generic/reminder_builder.dart";

class ReminderTile extends StatelessWidget {
	final int index;
	final double height;

	const ReminderTile({
		@required this.index,
		this.height = 65,
	});

	@override 
	Widget build (BuildContext context) {
		final Reminders reminders = Services.of(context).reminders;
		final Reminder reminder = reminders.reminders [index];
		
		return SizedBox (
			height: height, 
			child: Center (
				child: ListTile(
					title: Text (reminder.message),
					subtitle: Text (reminder.time.toString() ?? ""),
					onTap: () async => reminders.replaceReminder(
						index, 
						await ReminderBuilder.buildReminder(context, reminder),
					),
					trailing: IconButton (
						icon: Icon (
							Icons.remove_circle, 
							color: Theme.of(context).iconTheme.color
						),
						onPressed: () => reminders.deleteReminder(index),
					),
				),
			),
		);
	}
}