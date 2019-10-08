import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

class RemindersPage extends StatelessWidget {
	const RemindersPage();

	@override 
	Widget build(BuildContext context) => ModelListener<Reminders>(
		model: () => Services.of(context).reminders,
		dispose: false,
		// ignore: sort_child_properties_last
		child: const Center (
			child: Text (
				"You don't have any reminders yet",
				textScaleFactor: 1.5,
				textAlign: TextAlign.center,
			),
		),
		builder: (BuildContext context, Reminders model, Widget none) => Scaffold(
			bottomNavigationBar: const Footer(),
			drawer: const NavigationDrawer(),
			appBar: AppBar(
				title: const Text ("Reminders"),
				actions: [
					IconButton(
						icon: Icon (Icons.home),
						onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.home)
					)
				]
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () async => 
					model.addReminder(await ReminderBuilder.buildReminder(context)),
				child: const Icon (Icons.note_add),
			),
			body: model.reminders.isEmpty
				? none 
				: ListView.separated (
					itemCount: model.reminders.length,
					separatorBuilder: (_, __) => const Divider(),
					itemBuilder: (BuildContext context, int index) => 
						ReminderTile(index: index),
				)
		)
	);
}
