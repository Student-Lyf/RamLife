import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// The reminders page. 
/// 
/// Allows CRUD operations on reminders. 
class ResponsiveReminders extends NavigationItem<Reminders> {
	@override
	Reminders get model => super.model!;

	/// Creates the reminders page.
	ResponsiveReminders() : super(
		label: "Reminders", 
		icon: const Icon(Icons.notifications),
		model: Models.instance.reminders,
		shouldDispose: false,
	);

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
	Widget build(BuildContext context) => model.reminders.isEmpty 
		? const Center (
			child: Text (
				"You don't have any reminders yet",
				textScaleFactor: 1.5,
				textAlign: TextAlign.center,
			),
		)
		: ListView.separated (
			itemCount: model.reminders.length,
			separatorBuilder: (_, __) => const Divider(),
			itemBuilder: (BuildContext context, int index) => 
				ReminderTile(index: index),
		);
}
