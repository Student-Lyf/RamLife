import "package:flutter/material.dart";

import "package:ramaz/constants.dart" show SCHEDULE, CAN_EXIT;
import "package:ramaz/data/schedule.dart";
import "info_card.dart";

class NextClass extends StatelessWidget {
	final Period period;
	final Subject subject;
	final bool next;
	const NextClass(this.period, this.subject, {this.next = false});
	static final TextStyle white = TextStyle (
		color: Colors.white
	);

	@override Widget build (BuildContext context) => InfoCard (
		icon: next ? Icons.restore : Icons.school,
		title: period == null
			? "School is over"
			: "${next ? 'Next' : 'Current'} period: ${subject?.name ?? period.period}",
		children: period?.getInfo(subject),
		page: SCHEDULE + CAN_EXIT
	);
}
