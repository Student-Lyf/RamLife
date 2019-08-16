import "package:flutter/material.dart";

import "package:ramaz/data/schedule.dart" show Period, Subject, Day;
import "package:ramaz/data/note.dart";
import "package:ramaz/services/reader.dart";
import "package:ramaz/widgets/note_tile.dart";

class ClassPanel extends StatelessWidget {
	final String title, id;
	final List<Widget> children;
	final List<Note> notes;

	const ClassPanel ({
		@required this.title,
		@required this.children,
		@required this.id,
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
								(Note note) => NoteTile (
									note: note,
									onTap: () {},
									onDelete: () {},
									height: 65,
								)
							).toList()
						)
					)
				)
			)
		]
	);
}


class ClassList extends StatelessWidget {
	final Day day;
	final Iterable<Period> _periods;
	final String headerText;
	final Reader reader;

	ClassList ({
		@required this.day, 
		@required this.reader,
		this.headerText,
		Iterable periods,
	}) : _periods = periods ?? reader.student.getPeriods(day);

	@override Widget build (BuildContext context) => ListView (
		shrinkWrap: true,
		children: [
			if (headerText != null) 
				DrawerHeader (
					child: Center (
						child: Text (
							headerText,
							textScaleFactor: 2,
							textAlign: TextAlign.center,
						)
					)
				),
			..._periods.map (
				(Period period) {
					final Subject subject = reader.subjects[period.id];
					final List<String> info = period.getInfo(subject);
					// ListTile has the period number, so get rid of it
					info.removeWhere(
						(String description) => description.startsWith("Period:")
					);
					final List<Note> notes = reader.notes.where(
						(Note note) => note.repeat.doesApply(
							period: period.period,
							letter: day.letter,
							subject: subject,
						)
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
					);
				}
			).toList()
		]
	);
}
