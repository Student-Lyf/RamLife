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
		child: Center (
			child: Text (
				"You don't have any notes yet",
				textScaleFactor: 1.5,
				textAlign: TextAlign.center,
			),
		),
		builder: (BuildContext context, Notes model, Widget none) => Scaffold(
			bottomNavigationBar: Footer(),
			drawer: NavigationDrawer(),
			appBar: AppBar(
				title: Text ("Notes"),
				actions: [
					IconButton(
						icon: Icon (Icons.home),
						onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.home)
					)
				]
			),
			floatingActionButton: FloatingActionButton(
				child: Icon (Icons.note_add),
				onPressed: () async => 
					model.addNote(await NotesBuilder.buildNote(context)),
			),
			body: model.notes.isEmpty
				? none 
				: ListView.separated (
					itemCount: model.notes.length,
					separatorBuilder: (_, __) => Divider(),
					itemBuilder: (BuildContext context, int index) => 
						NoteTile(index: index),
				)
		)
	);
}
