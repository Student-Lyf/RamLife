import "package:flutter/material.dart";

import "package:ramaz/data/note.dart";

import "package:ramaz/services/notes.dart";

import "package:ramaz/widgets/services.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";
import "package:ramaz/pages/notes_builder.dart";

class NoteTile extends StatelessWidget {
	final int index;
	final double height;

	const NoteTile({
		@required this.index,
		this.height = 65,
	});

	@override 
	Widget build (BuildContext context) => SizedBox (
		height: height, 
		child: Center (
			child: ChangeNotifierListener(
				model: () => Services.of(context).notes,
				dispose: false,
				child: Icon (
					Icons.remove_circle, 
					color: Theme.of(context).iconTheme.color
				),
				builder: (BuildContext context, Notes notes, Widget icon) {
					final Note note = notes.notes [index];
					return ListTile(
						title: Text (note.message),
						subtitle: Text (note.repeat?.toString() ?? ""),
						onTap: () async => notes.replaceNote(
							index, 
							await NotesBuilder.buildNote(context, note),
						),
						trailing: IconButton (
							icon: icon,
							onPressed: () => notes.deleteNote(index),
						),
					);
				}
			),
		),
	);
}