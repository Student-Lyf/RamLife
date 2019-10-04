import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

class NotesPage extends StatelessWidget {
	@override 
	Widget build(BuildContext context) => ModelListener<Notes>(
		model: () => Services.of(context).notes,
		dispose: false,
		// ignore: sort_child_properties_last
		child: const Center (
			child: Text (
				"You don't have any notes yet",
				textScaleFactor: 1.5,
				textAlign: TextAlign.center,
			),
		),
		builder: (BuildContext context, Notes model, Widget none) => Scaffold(
			bottomNavigationBar: const Footer(),
			drawer: const NavigationDrawer(),
			appBar: AppBar(
				title: const Text ("Notes"),
				actions: [
					IconButton(
						icon: Icon (Icons.home),
						onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.home)
					)
				]
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () async => 
					model.addNote(await NotesBuilder.buildNote(context)),
				child: const Icon (Icons.note_add),
			),
			body: model.notes.isEmpty
				? none 
				: ListView.separated (
					itemCount: model.notes.length,
					separatorBuilder: (_, __) => const Divider(),
					itemBuilder: (BuildContext context, int index) => 
						NoteTile(index: index),
				)
		)
	);
}
