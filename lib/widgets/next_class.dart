import "package:flutter/material.dart";

import "package:ramaz/constants.dart" show SCHEDULE;

import "package:ramaz/models/schedule.dart";

import "package:ramaz/data/schedule.dart";

import "package:ramaz/widgets/info_card.dart";
import "package:ramaz/widgets/note_tile.dart";
import "package:ramaz/widgets/services.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";

class NextClass extends StatelessWidget {
	static const TextStyle white = TextStyle (
		color: Colors.white
	);
	static const double notePadding = 10;

	final bool next;

	NextClass({this.next = false});

	@override 
	Widget build (BuildContext context) => ChangeNotifierListener(
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
