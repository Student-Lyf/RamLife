import "package:flutter/material.dart";

import "package:ramaz/data/note.dart";

class NoteTile extends StatelessWidget {
	final Note note;
	final VoidCallback onTap, onDelete;

	final double height;

	const NoteTile({
		@required this.note,
		@required this.onTap,
		@required this.onDelete,
		this.height = 65,
	});

	@override 
	Widget build (BuildContext context) => SizedBox (
		height: height, 
		child: Center (
			child: ListTile (
				title: Text (note.message),
				subtitle: Text (note.repeat?.toString() ?? ""),
				onTap: onTap,
				trailing: IconButton (
					icon: Icon (Icons.remove_circle, color: Theme.of(context).iconTheme.color),
					onPressed: onDelete,
				),
			),
		),
	);
}