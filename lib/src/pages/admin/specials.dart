import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A page to show the admin's custom specials. 
class AdminSpecialsPage extends StatelessWidget {

	const AdminSpecialsPage();

	// If the user is on this page, they are an admin.
	// So, model.admin != null
	@override
	Widget build(BuildContext context) => ModelListener(
		model: () => AdminScheduleModel(),
		builder: (_, AdminScheduleModel model, __) => ResponsiveScaffold(
			appBar: AppBar(title: const Text("Custom schedules")),
			drawer: const NavigationDrawer(),
			floatingActionButton: FloatingActionButton(
				onPressed: () async {
					final Schedule? schedule = await ScheduleBuilder.buildSpecial(context);
					if (schedule == null) {
						return;
					}
					await model.createSchedule(schedule);
				},
				child: const Icon(Icons.add),
			),
			bodyBuilder: (_) => Padding(
				padding: const EdgeInsets.all(20), 
				child: model.schedules.isEmpty
					? const Center (
						child: Text (
							"There are no schedules yet. Feel free to add one.",
							textScaleFactor: 1.5,
							textAlign: TextAlign.center,
						)
					)
					: ListView(
						children: [
							for (final Schedule schedule in model.schedules)
								ListTile(
									title: Text(schedule.name),
									onTap: () async {
										final Schedule? newSchedule = 
											await ScheduleBuilder.buildSpecial(context, schedule);
										if (newSchedule != null) {
											await model.createSchedule(newSchedule);
										}
									},
								)
						]
				)
			)
		)
	);
}

