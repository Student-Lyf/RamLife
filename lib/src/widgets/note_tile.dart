import "package:flutter/material.dart";

import "services.dart";
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
	Widget build (BuildContext context) {
		final Notes notes = Services.of(context).notes;
		final Note note = notes.notes [index];
		
		return SizedBox (
			height: height, 
			child: Center (
				child: ListTile(
					title: Text (note.message),
					subtitle: Text (note.time.toString() ?? ""),
					onTap: () async => notes.replaceNote(
						index, 
						await NotesBuilder.buildNote(context, note),
					),
					trailing: IconButton (
						icon: Icon (
							Icons.remove_circle, 
							color: Theme.of(context).iconTheme.color
						),
						onPressed: () => notes.deleteNote(index),
					),
				),
			),
		);
	}
}