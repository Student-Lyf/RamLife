import "package:flutter/material.dart";

import "package:ramaz/data/note.dart";

class NoteTile extends StatelessWidget {
	final Note note;

	const NoteTile({
		@required this.note,
	});

	@override 
	Widget build (BuildContext context) => ListTile (
		title: Text (note.message),
		subtitle: Text (note.repeat.toString()),
	);
}