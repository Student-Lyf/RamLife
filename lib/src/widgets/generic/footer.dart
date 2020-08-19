import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// A footer to display all around the app. 
/// 
/// The footer displays the next period, and alerts the user if there is a 
/// reminder or activity. 
/// 
/// The footer should be displayed on every page where the current schedule is 
/// not being shown. 
class Footer extends StatelessWidget {
	/// A scale factor for the footer text. 
	static const double textScale = 1.25;

	@override Widget build (BuildContext context) => ModelListener<Schedule>(
		model: () => Models.schedule,
		dispose: false,
		// ignore: sort_child_properties_last
		child: Container(height: 0, width: 0),
		builder: (BuildContext context, Schedule schedule, Widget blank) =>
			schedule.nextPeriod == null ? blank : BottomSheet (
				enableDrag: false,
				onClosing: () {},
				builder: (BuildContext context) => GestureDetector(
					onTap: !Models.reminders.hasNextReminder ? null : 
						() {
							final NavigatorState nav = Navigator.of(context);
							if (nav.canPop()) {
								nav.pop();
							}
							nav.pushReplacementNamed(Routes.home);
						},
					child: SizedBox (
						height: 70,
						child: Align (
							child: Column (
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Text (
										"Next: ${schedule.nextPeriod.getName(schedule.nextSubject)}",
										textScaleFactor: textScale
									),
									Text (
										(schedule.nextPeriod
											.getInfo(schedule.nextSubject)
											..removeWhere(
												(String str) => (
													str.startsWith("Period: ") || 
													str.startsWith("Teacher: ")
												)
											)
										).join (". "),
										textScaleFactor: textScale,
									),
									if (schedule.nextPeriod?.activity != null) 
										const Text("There is an activity"),
									if (Models.reminders.hasNextReminder) 
										const Text ("Click to see reminder"),
								]
							)
						)
					)
				)
			)
		);
}