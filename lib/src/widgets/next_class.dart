import "package:flutter/material.dart";

import "info_card.dart";
import "note_tile.dart";
import "services.dart";
import "change_notifier_listener.dart";

import "package:ramaz/constants.dart" show SCHEDULE;
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

class NextClass extends StatelessWidget {
	static const TextStyle white = TextStyle (
		color: Colors.white
	);
	static const double notePadding = 10;

	final bool next;

	NextClass({this.next = false});

	@override 
	Widget build (BuildContext context) => ChangeNotifierListener<Schedule>(
		model: () => Services.of(context).schedule,
		dispose: false,
		builder: (BuildContext context, Schedule schedule, Widget child) {
			final Period period = next ? schedule.nextPeriod : schedule.period;
			final Subject subject = schedule.subjects [period?.id];
			final List<int> notes = next 
				? schedule.notes.nextNotes 
				: schedule.notes.currentNotes;

			return Column(
				children: [
					InfoCard (
						icon: next ? Icons.restore : Icons.school,
						children: period?.getInfo(subject),
						page: SCHEDULE,
						title: period == null
							? "School is over"
							: "${next ? 'Next' : 'Current'} period: " 
								+ (subject?.name ?? period.period),
					),

					...notes.map(
						(int index) => Padding (
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
					)
				]
			);
		}
	);
}
