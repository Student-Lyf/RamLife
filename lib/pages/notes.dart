import "package:flutter/material.dart";

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/preferences.dart";
import "package:ramaz/models/notes.dart";
import "package:ramaz/data/note.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";
import "package:ramaz/pages/drawer.dart" show NavigationDrawer;
import "package:ramaz/pages/notes_builder.dart";

import "package:ramaz/widgets/note_tile.dart";

class NotesPage extends StatefulWidget {
	final Reader reader;
	final Preferences prefs;

	const NotesPage({
		@required this.reader,
		@required this.prefs,
	});

	@override 
	NotesPageState createState() => NotesPageState();
}

class NotesPageState extends State<NotesPage> {
	NotesPageModel model;

	@override initState() {
		super.initState();
		model = NotesPageModel(reader: widget.reader);
	}

	@override 
	Widget build(BuildContext context) => ChangeNotifierListener<NotesPageModel>(
		model: model,
		builder: (BuildContext context, NotesPageModel model, Widget child) => Scaffold(
			drawer: NavigationDrawer(widget.prefs),
			appBar: AppBar(title: Text ("Notes")),
			floatingActionButton: FloatingActionButton(
				child: Icon (Icons.note_add),
				onPressed: () async => model.saveNote (await showBuilder(context)),
			),
			body: ListView.builder (
				itemCount: model.notes.length,
				itemBuilder: (BuildContext context, int index) => NoteTile(
					note: model.notes [index],
					onTap: () async => model.replace(
						index, 
						await showBuilder(context, model.notes [index]),
					),
					onDelete: () => model.deleteNote(index),
				),
			)
		)
	);

	Future<Note> showBuilder(BuildContext context, [Note note]) => 
		showDialog<Note>(
			context: context,
			builder : (BuildContext context) => 
				NotesBuilder(reader: widget.reader, note: note)
		);
}