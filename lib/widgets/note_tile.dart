import "package:flutter/material.dart";

import "package:ramaz/data/note.dart";

class NoteTile extends StatelessWidget {
	final Note note;
	final VoidCallback onTap, onDelete;

	const NoteTile({
		@required this.note,
		@required this.onTap,
		@required this.onDelete
	});

	@override 
	Widget build (BuildContext context) => ListTile (
		title: Text (note.message),
		subtitle: Text (note.repeat?.toString() ?? ""),
		onTap: onTap,
		trailing: IconButton (
			icon: Icon (Icons.remove_circle),
			onPressed: onDelete,
		),
	);
}