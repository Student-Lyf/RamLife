import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A page to show the admin's custom schedules. 
class AdminSchedulesPage extends StatefulWidget {
	/// Creates a page for admins to manage schedules.
	const AdminSchedulesPage();

	@override
	AdminScheduleState createState() => AdminScheduleState();
}

/// The state for the scheudules page. 
/// 
/// Creates and listens to an [AdminScheduleModel].
class AdminScheduleState extends
	ModelListener<AdminScheduleModel, AdminSchedulesPage> 
{
	@override
	AdminScheduleModel getModel() => AdminScheduleModel();

	// If the user is on this page, they are an admin.
	// So, model.admin != null
	@override
	Widget build(BuildContext context) => ResponsiveScaffold(
		appBar: AppBar(title: const Text("Custom schedules")),
		drawer: const RamlifeDrawer(),
		floatingActionButton: FloatingActionButton(
			onPressed: () async {
				final Schedule? schedule = await ScheduleBuilder.buildSchedule(context);
				if (schedule == null) {
					return;
				}
				await model.createSchedule(schedule);
			},
			child: const Icon(Icons.add),
		),
		body: Padding(
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
										await ScheduleBuilder.buildSchedule(context, preset: schedule);
									if (newSchedule != null) {
										await model.replaceSchedule(newSchedule);
									}
								},
							)
					]
			)
		)
	);
}

