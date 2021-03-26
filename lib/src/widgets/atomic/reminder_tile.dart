import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";

/// A widget to represent a [Reminder].
/// 
/// From the widget, the user will be able to delete or modify the reminder. 
class ReminderTile extends StatelessWidget {
	/// The index of this reminder in [Reminders.reminders].
	final int index;

	/// The height of this tile. 
	final double height;

	/// Creates a reminder tile.
	const ReminderTile({
		required this.index,
		this.height = 65,
	});

	@override 
	Widget build (BuildContext context) {
		// The data model.
		final Reminders reminders = Models.instance.reminders;

		// The reminder being represented
		final Reminder reminder = reminders.reminders [index];
		
		return SizedBox (
			height: height, 
			child: Center (
				child: ListTile(
					title: Text (reminder.message),
					subtitle: Text(reminder.time.toString()),
					onTap: () async {
						if (!Models.instance.schedule.isValidReminder(reminder)) {
							reminders.deleteReminder(index);
							ScaffoldMessenger.of(context).showSnackBar(
								const SnackBar(content: Text("Deleted outdated reminder"))
							);
							return;
						}
						reminders.replaceReminder(
							index, 
							await ReminderBuilder.buildReminder(context, reminder),
						);
						},
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