import "package:flutter/material.dart";

import "package:ramaz/data/schedule.dart" show Period, Subject, Day;
import "package:ramaz/data/note.dart";
import "package:ramaz/services/reader.dart";
import "package:ramaz/widgets/note_tile.dart";
import "package:ramaz/pages/notes_builder.dart";
import "package:ramaz/models/notes.dart";

class ClassPanel extends StatelessWidget {
	final String title, id;
	final List<Widget> children;
	final List<int> notes;
	final NoteEditor editor;

	const ClassPanel ({
		@required this.title,
		@required this.children,
		@required this.id,
		@required this.editor,
		this.notes,
	});

	@override Widget build (BuildContext context) => ExpansionTile (
		title: Text (title),
		children: [
			Padding (
				padding: EdgeInsets.only(left: 30),
				child: Align (
					alignment: Alignment.centerLeft,					
					child: Column (
						crossAxisAlignment: CrossAxisAlignment.start,
						children: <Widget>[
							...children, 
							if (id != null) Text ("ID: $id")
						].map<Widget> (
							(Widget child) => Padding (
								padding: const EdgeInsets.symmetric(vertical: 5),
								child: child
							) 
						).toList() + (
							notes.map(
								(int index) => NoteTile (
									note: editor.notes [index],
									onTap: () async => editor.replaceNote(
										index, 
										await NotesBuilder.buildNote(
											context, 
											editor.notes [index],
										),
									),
									onDelete: () => editor.deleteNote(index),
									height: 60,
								)
							).toList()
						)
					)
				)
			)
		]
	);
}

class ClassList extends StatefulWidget {
	final Day day;
	final Iterable<Period> periods;
	final String headerText;
	final Reader reader;
	final NoteEditor noteModel;

	ClassList ({
		@required this.day, 
		@required this.reader,
		@required this.noteModel,
		this.headerText,
		this.periods,
	});

	@override 
	ClassListState createState() => ClassListState();
}

class ClassListState extends State<ClassList> {
	Iterable<Period> periods;

	void listener() => setState (() {});

	@override 
	void initState() {
		super.initState();
		periods = widget.periods ?? widget.reader.student.getPeriods(widget.day);
		widget.noteModel.addListener(listener);
	}

	@override 
	void dispose() {
		widget.noteModel.removeListener(listener);
		super.dispose();
	}

	@override 
	Widget build (BuildContext context) => ListView (
		shrinkWrap: true,
		children: [
			if (widget.headerText != null) 
				DrawerHeader (
					child: Center (
						child: Text (
							widget.headerText,
							textScaleFactor: 2,
							textAlign: TextAlign.center,
						)
					)
				),
			...periods.map (
				(Period period) {
					final Subject subject = widget.reader.subjects[period.id];
					final List<String> info = period.getInfo(subject);
					// ListTile has the period number, so get rid of it
					info.removeWhere(
						(String description) => description.startsWith("Period:")
					);

					final List<int> notes = Note.getNotes(
						period: period.period,
						letter: widget.day.letter,
						subject: subject,
						notes: widget.noteModel.notes,
					).toList();
					return ClassPanel (
						notes: notes,
						title: (
							"${period.period}"
							"${int.tryParse (period.period) == null ? "" : ": "}"
							"${period.getName(subject)}"
						),
						id: period.id,
						children: info.map (
							(String description) => Text (description)
						).toList(),
						editor: widget.noteModel,
					);
				}
			).toList()
		]
	);
}
