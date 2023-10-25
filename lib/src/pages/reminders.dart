import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// The reminders page. 
/// 
/// Allows CRUD operations on reminders. 
class RemindersPage extends StatelessWidget {
	@override
	Widget build(BuildContext context) => ProviderConsumer.value(
		value: Models.instance.reminders,
		builder: (model, child) => ResponsiveScaffold(
			enableNavigation: true,
			drawer: const RamlifeDrawer(),
			appBar: AppBar(title: const Text ("Reminders")),
			floatingActionButton: FloatingActionButton(
				onPressed: () async {
					final reminder = await ReminderBuilder.buildReminder(context);
					model.addReminder(reminder);
				},
				child: const Icon (Icons.note_add),
			),
			body: model.reminders.isEmpty 
				? const Center(
					child: Text(
						"You don't have any reminders yet",
						textScaleFactor: 1.5,
						textAlign: TextAlign.center,
					),
				)
				: ListView.separated(
					itemCount: model.reminders.length,
					separatorBuilder: (_, __) => const Divider(),
					itemBuilder: (BuildContext context, int index) => ReminderTile(index: index),
				),
		),
	);
}
