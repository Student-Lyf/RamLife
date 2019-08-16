import "package:flutter/material.dart";
import "package:flutter/foundation.dart";

import "package:ramaz/constants.dart" show SCHEDULE, CAN_EXIT;

import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/note.dart";

import "package:ramaz/widgets/info_card.dart";
import "package:ramaz/widgets/note_tile.dart";
import "package:ramaz/pages/notes_builder.dart";

import "package:ramaz/models/notes.dart";
import "package:ramaz/models/home.dart";


class NextClass extends StatelessWidget {
	static final TextStyle white = TextStyle (
		color: Colors.white
	);

	final Period period;
	final Subject subject;
	final NoteEditor notesModel;
	final HomeModel model;
	final List<int> notes;
	final bool next;

	NextClass({
		@required this.model,
		this.next = false,
	}) :
		period = next ? model.nextPeriod : model.period,
		subject = model.reader.subjects [
			(next ? model.nextPeriod : model.period)?.id
		],
		notesModel = NoteEditor(model.reader),
		notes = next ? model.nextNotes : model.currentNotes;

	@override Widget build (BuildContext context) {
		final Widget child = InfoCard (
			icon: next ? Icons.restore : Icons.school,
			title: period == null
				? "School is over"
				: "${next ? 'Next' : 'Current'} period: ${subject?.name ?? period.period}",
			children: period?.getInfo(subject),
			page: SCHEDULE + CAN_EXIT
		);

		return notes.isEmpty ? child : Column (
			children: <Widget>[
				child, 
				...(
					notes.map(
						(int index) => Padding (
							padding: EdgeInsets.symmetric(horizontal: 10), 
							child: Container (
								foregroundDecoration: ShapeDecoration (
									shape: RoundedRectangleBorder(
										side: BorderSide(color: Theme.of(context).primaryColor),
										borderRadius: BorderRadius.circular (20),
									),
								),
								child: StatefulBuilder(
									builder: (_, StateSetter setState) => NoteTile(
										note: notesModel.notes [index], 
										onTap: () async {
											await notesModel.replaceNote(
												index,
												await showDialog<Note> (
													context: context,
													builder: (_) => NotesBuilder(
														reader: notesModel.reader,
														note: notesModel.notes [index],
													),
												)
											);
											setState(() {});
										},
										onDelete: () => model.noteModel.deleteNote(index),
									)
								)
							)
						)
					)
				)
			]
		);
	}
}
