import "package:flutter/material.dart";

import "package:ramaz/data/schedule.dart" show Period, Subject;
import "package:ramaz/services/reader.dart";

class ClassPanel extends StatelessWidget {
	final String title, id;
	final List <Widget> children;

	const ClassPanel ({
		@required this.title,
		@required this.children,
		@required this.id,
	});

	@override Widget build (BuildContext context) => ExpansionTile (
		// title: ListTile (
		// 	title: Text (title),
		// 	subtitle: Text (id ?? ""),
		// 	contentPadding: EdgeInsets.symmetric(vertical: 0),
		// ),
		title: Text (title),
		children: [
			Align (
				alignment: const Alignment (-0.75, 0),
				child: Column (
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						...children, 
						if (id != null) Text ("ID: $id")
					].map (
						(Widget child) => Padding (
							padding: const EdgeInsets.symmetric(vertical: 5),
							child: child
						) 
					).toList()
				)
			)
		]
	);
}


class ClassList extends StatelessWidget {
	final Iterable<Period> periods;
	final String headerText;
	final Reader reader;
	ClassList ({
		@required this.periods, 
		@required this.reader,
		this.headerText
	});

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
			...periods.map (
				(Period period) {
					final Subject subject = reader.subjects[period.id];
					final List<String> info = period.getInfo(subject);
					// ListTile has the period number, so get rid of it
					info.removeWhere(
						(String description) => description.startsWith("Period:")
					);
					return ClassPanel (
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
