import "package:flutter/material.dart";

import "package:ramaz/constants.dart" show SCHEDULE;
import "package:ramaz/data/schedule.dart";
import "info_card.dart";

class NextClass extends StatelessWidget {
	final Period period;
	const NextClass(this.period);
	static final TextStyle white = TextStyle (
		color: Colors.white
	);

	@override Widget build (BuildContext context) {
		final Subject subject = period?.subject;
		return InfoCard (
			icon: Icons.school,
			title: period == null
				? "School is over"
				: "Current period: ${subject?.name ?? period.period}",
			children: period?.getInfo(),
			page: SCHEDULE
		);
	}
}
