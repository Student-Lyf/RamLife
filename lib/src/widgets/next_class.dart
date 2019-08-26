import "package:flutter/material.dart";

import "info_card.dart";
import "note_tile.dart";
import "services.dart";
import "model_listener.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

class NextClass extends StatelessWidget {
	static const TextStyle white = TextStyle (color: Colors.white);
	static const double notePadding = 10;

	final bool next;
	final Period period;
	final Subject subject;

	const NextClass({
		@required this.period,
		@required this.subject,
		this.next = false
	});

	@override 
	Widget build (BuildContext context) => ModelListener<Notes>(
		model: () => Services.of(context).notes,
		dispose: false,
		builder: (BuildContext context, Notes notes, Widget child) => Column(
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

				for (final int index in next ? notes.nextNotes : notes.currentNotes) 
					Padding (
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
		)
	);
}
