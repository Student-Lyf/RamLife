import "package:flutter/material.dart";

import "package:ramaz/widgets/services.dart";

import "package:ramaz/services/notes.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";
import "package:ramaz/pages/drawer.dart" show NavigationDrawer;
import "package:ramaz/pages/notes_builder.dart";

import "package:ramaz/widgets/note_tile.dart";

class NotesPage extends StatelessWidget {
	@override 
	Widget build(BuildContext context) => ChangeNotifierListener<Notes>(
		model: () => Services.of(context).notes,
		dispose: false,
		builder: (BuildContext context, Notes model, _) => Scaffold(
			drawer: NavigationDrawer(),
			appBar: AppBar(title: Text ("Notes")),
			floatingActionButton: FloatingActionButton(
				child: Icon (Icons.note_add),
				onPressed: () async => 
					model.addNote(await NotesBuilder.buildNote(context)),
			),
			body: model.notes.isEmpty
				? Center (
					child: Text (
						"You don't have any notes yet",
						textScaleFactor: 1.5,
						textAlign: TextAlign.center,
					),
				) 
				: ListView.separated (
					itemCount: model.notes.length,
					separatorBuilder: (_, __) => Divider(),
					itemBuilder: (BuildContext context, int index) => 
						NoteTile(index: index),
				)
		)
	);
}