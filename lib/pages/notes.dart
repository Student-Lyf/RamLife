import "package:flutter/material.dart";

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/preferences.dart";
import "package:ramaz/models/notes.dart";
import "package:ramaz/data/note.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";
import "package:ramaz/pages/drawer.dart" show NavigationDrawer;

import "package:ramaz/widgets/note_tile.dart";

class NotesPage extends StatelessWidget {
	final Reader reader;
	final Preferences prefs;

	const NotesPage({
		@required this.reader,
		@required this.prefs,
	});

	@override 
	Widget build(BuildContext context) => ChangeNotifierListener<NotesPageModel>(
		child: FloatingActionButton(
			child: Icon (Icons.note_add),
			onPressed: () => print ("Add new note"),
		),
		model: NotesPageModel(reader: reader),
		builder: (BuildContext context, NotesPageModel model, Widget child) => Scaffold(
			drawer: NavigationDrawer(prefs),
			appBar: AppBar(title: Text ("Notes")),
			floatingActionButton: child,
			body: ListView (
				children: model.notes.map(
					(Note note) => NoteTile(note: note)
				).toList(),
			)
		)
	);
}