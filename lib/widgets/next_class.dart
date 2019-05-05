import "package:flutter/material.dart";

import "package:ramaz/constants.dart" show SCHEDULE;
import "package:ramaz/data/schedule.dart";
import "info_card.dart";

class NextClass extends StatelessWidget {
	final Period period;
	final Subject subject;
	const NextClass(this.period, this.subject);
	static final TextStyle white = TextStyle (
		color: Colors.white
	);

	@override Widget build (BuildContext context) => InfoCard (
		icon: Icons.school,
		title: period == null
			? "School is over"
			: "Current period: ${subject?.name ?? period.period}",
		children: period?.getInfo(subject),
		page: SCHEDULE
	);
}
