import "package:flutter/material.dart";

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/preferences.dart";
import "package:ramaz/models/notes.dart";
import "package:ramaz/data/note.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";
import "package:ramaz/pages/drawer.dart" show NavigationDrawer;
import "package:ramaz/pages/notes_builder.dart";

import "package:ramaz/widgets/note_tile.dart";

class NotesPage extends StatelessWidget {
	final Reader reader;
	final Widget drawer;

	NotesPage({
		@required this.reader,
		@required Preferences prefs,
	}) : drawer = NavigationDrawer(prefs);

	@override 
	Widget build(BuildContext context) => ChangeNotifierListener<NotesPageModel>(
		model: () => NotesPageModel(reader: reader),
		builder: (BuildContext context, NotesPageModel model, Widget child) => Scaffold(
			drawer: drawer,
			appBar: AppBar(title: Text ("Notes")),
			floatingActionButton: FloatingActionButton(
				child: Icon (Icons.note_add),
				onPressed: () async => model.saveNote (await showBuilder(context)),
			),
			body: ListView.separated (
				itemCount: model.notes.length,
				separatorBuilder: (_, __) => Divider(),
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
				NotesBuilder(reader: reader, note: note)
		);
}