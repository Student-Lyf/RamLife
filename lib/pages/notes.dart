import "package:flutter/material.dart";

import "package:ramaz/services/reader.dart";
import "package:ramaz/models/notes.dart";
import "package:ramaz/data/note.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";

import "package:ramaz/widgets/note_tile.dart";

class NotesPage extends StatelessWidget {
	final Reader reader;

	const NotesPage({
		@required this.reader,
	});

	@override 
	Widget build(BuildContext context) => ChangeNotifierListener<NotesPageModel>(
		child: FloatingActionButton(
			child: Icon (Icons.add),
			onPressed: () => print ("Add new note"),
		),
		model: NotesPageModel(reader: reader),
		builder: (BuildContext context, NotesPageModel model, Widget child) => Scaffold(
			appBar: AppBar(title: Text ("Notes")),
			body: ListView (
				children: model.notes.map(
					(Note note) => NoteTile(note: note)
				).toList(),
			)
		)
	);
}