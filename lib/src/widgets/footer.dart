import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

class Footer extends StatelessWidget {
	static const double textScale = 1.25;

	@override Widget build (BuildContext context) => ChangeNotifierListener<Schedule>(
			model: () => Services.of(context).schedule,
			dispose: false,
			child: Container(height: 0, width: 0),
			builder: (BuildContext context, Schedule schedule, Widget blank) =>
				schedule.period == null ? blank : BottomSheet (
					enableDrag: false,
					onClosing: () {},
					builder: (BuildContext context) => GestureDetector(
						onTap: !schedule.notes.hasNote ? null : 
							() {
								final NavigatorState nav = Navigator.of(context);
								if (nav.canPop()) nav.pop();
								nav.pushReplacementNamed("home");
							},
						child: SizedBox (
							height: 70,
							child: Align (
								child: Column (
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text (
											"Next: ${schedule.period.getName (schedule.subject)}",
											textScaleFactor: textScale
										),
										Text (
											(schedule.period
												.getInfo(schedule.subject)
												..removeWhere(
													(String str) => (
														str.startsWith("Period: ") || 
														str.startsWith("Teacher: ")
													)
												)
											).join (". "),
											textScaleFactor: textScale,
										),
										if (schedule.notes.hasNote) Text ("Click to see note"),
									]
								)
							)
						)
					)
				)
			);
}