import "package:flutter/material.dart";

import "services.dart";
import "change_notifier_listener.dart";
import "notes_builder.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

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
			child: ChangeNotifierListener<Notes>(
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
						subtitle: Text (note.time.toString() ?? ""),
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