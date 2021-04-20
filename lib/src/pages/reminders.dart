import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// The reminders page. 
/// 
/// Allows CRUD operations on reminders. 
class ResponsiveReminders extends NavigationItem {
	/// The data model for reminders.
	final Reminders model = Models.instance.reminders;

	/// Creates the reminders page.
	ResponsiveReminders() : 
		super(label: "Reminders", icon: const Icon(Icons.notifications));

	@override
	AppBar get appBar => AppBar(title: const Text ("Reminders"));

	@override
	Widget get floatingActionButton => Builder(
		builder: (BuildContext context) => FloatingActionButton(
			onPressed: () async => model
				.addReminder(await ReminderBuilder.buildReminder(context)),
			child: const Icon (Icons.note_add),
		)
	);

	@override 
	Widget build(BuildContext context) => ModelListener<Reminders>(
		model: () => Models.instance.reminders,
		dispose: false,
		// ignore: sort_child_properties_last
		child: const Center (
			child: Text (
				"You don't have any reminders yet",
				textScaleFactor: 1.5,
				textAlign: TextAlign.center,
			),
		),
		builder: (_, Reminders model, Widget? empty) => model.reminders.isEmpty
			? empty!  // widget is supplied above
			: ListView.separated (
				itemCount: model.reminders.length,
				separatorBuilder: (_, __) => const Divider(),
				itemBuilder: (BuildContext context, int index) => 
					ReminderTile(index: index),
			)
	);
}
