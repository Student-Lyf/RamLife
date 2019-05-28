import "package:flutter/material.dart";

import "package:ramaz/data/schedule.dart";

class Footer extends StatelessWidget {
	static const double textScale = 1.25;

	final Period period;
	final Subject subject;
	const Footer ({
		@required this.period,
		@required this.subject,
	});

	@override Widget build (BuildContext context) => period == null 
		? Container(height: 0, width: 0) 
		: BottomSheet (
			enableDrag: false,
			onClosing: () {},
			builder: (BuildContext context) => SizedBox (
				height: 70,
				child: Align (
					child: Column (
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Text (
								(
									"Next: " + 
									period.getName (subject)
								),
								textScaleFactor: textScale
							),
							Text (
								(period
									.getInfo(subject)
									..removeWhere(
										(String str) => 
											str.startsWith("Period: ") || 
											str.startsWith("Teacher: ")
									)
								).join (". "),
								textScaleFactor: textScale,
							)
						]
					)
				)
			)
		);
}