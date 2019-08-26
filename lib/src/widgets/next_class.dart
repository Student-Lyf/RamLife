import "package:flutter/material.dart";

import "info_card.dart";
import "note_tile.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";

class NextClass extends StatelessWidget {
	static const TextStyle white = TextStyle (color: Colors.white);
	static const double notePadding = 10;

	final bool next;
	final Period period;
	final Subject subject;
	final List<int> notes;

	const NextClass({
		@required this.period,
		@required this.subject,
		@required this.notes,
		this.next = false
	});

	@override 
	Widget build (BuildContext context) => Column(
		children: [
			InfoCard (
				icon: next ? Icons.restore : Icons.school,
				children: period?.getInfo(subject),
				page: Routes.SCHEDULE,
				title: period == null
					? "School is over"
					: "${next ? 'Next' : 'Current'} period: " 
						+ (subject?.name ?? period.period),
			),

			for (final int index in notes) Padding (
				padding: EdgeInsets.symmetric(horizontal: notePadding),
				child: Container (
					foregroundDecoration: ShapeDecoration(
						shape: RoundedRectangleBorder(
							side: BorderSide(color: Theme.of(context).primaryColor),
							borderRadius:  BorderRadius.circular (20),
						)
					),
					child: NoteTile(index: index),
				)
			)
		]
	);
}
