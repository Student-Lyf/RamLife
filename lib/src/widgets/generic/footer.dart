import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A footer to display all around the app. 
/// 
/// The footer displays the next period, and alerts the user if there is a 
/// reminder or activity. 
/// 
/// The footer should be displayed on every page where the current schedule is 
/// not being shown. 
class Footer extends StatefulWidget {
	/// A scale factor for the footer text. 
	static const double textScale = 1.25;

	@override
	FooterState createState() => FooterState();
}

/// The state of the footer. 
/// 
/// The footer refreshes whenever the schedule or reminders change. 
class FooterState extends ModelListener<ScheduleModel, Footer> {
	/// Doesn't dispose the data model since it's used elsewhere.
	FooterState() : super(shouldDispose: false);

	@override
	ScheduleModel getModel() => Models.instance.schedule;

	@override 
	Widget build (BuildContext context) => model.nextPeriod == null ? Container()
	 : BottomSheet (
			enableDrag: false,
			onClosing: () {},
			builder: (BuildContext context) => GestureDetector(
				onTap: !Models.instance.reminders.hasNextReminder ? null : 
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
									// ternary already checked for schedule.nextPeriod == null
									"Next: ${model.nextPeriod!.getName(model.nextSubject)}",
									textScaleFactor: Footer.textScale
								),
								Text (
									// ternary already checked for schedule.nextPeriod == null
									(model.nextPeriod!
										.getInfo(model.nextSubject)
										..removeWhere(
											(String str) => (
												str.startsWith("Period: ") || 
												str.startsWith("Teacher: ")
											)
										)
									).join (". "),
									textScaleFactor: Footer.textScale,
								),
								if (model.nextPeriod?.activity != null) 
									const Text("There is an activity"),
								if (Models.instance.reminders.hasNextReminder) 
									const Text ("Click to see reminder"),
							]
						)
					)
				)
			)
		);
}