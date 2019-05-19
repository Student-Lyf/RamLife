import "package:flutter/material.dart";

import "package:ramaz/data/schedule.dart" show Period, Subject;
import "package:ramaz/services/reader.dart";

class ClassPanel extends StatelessWidget {
	final String title;
	final List <Widget> children;

	const ClassPanel ({
		@required this.title,
		@required this.children,
	});

	@override Widget build (BuildContext context) => ExpansionTile (
		title: Text(title),
		children: [
			Align (
				alignment: const Alignment (-0.75, 0),
				child: Column (
					crossAxisAlignment: CrossAxisAlignment.start,
					children: children.map (
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
	const ClassList ({
		@required this.periods, 
		@required this.reader,
		this.headerText
	});

	@override Widget build (BuildContext context) => ListView (
		shrinkWrap: true,
		children: 
			(headerText == null 
					? const <Widget> [] 
					: <Widget>[
						DrawerHeader (
							child: Center (
								child: Text (
									headerText,
									textScaleFactor: 2,
									textAlign: TextAlign.center,
								)
							)
						)
					]
			) + periods.map (
			(Period period) {
				final Subject subject = reader.subjects[period.id];
				final List<String> info = period.getInfo(subject);
				// ListTile has the period number, so get rid of it
				info.removeWhere(
					(String description) => description.startsWith("Period:")
				);
				String title = period.period;
				if (period.id == -1) title += ": Free period";
				else if (subject != null) title += ": ${subject.name}";
				return ClassPanel (
					// title: "${period.period}${subject == null ? '' : ': ${subject.name}'}",
					title: title,
					children: info.map (
						(String description) => Text (description)
					).toList(),
				);
			}
		).toList()
	);
}
