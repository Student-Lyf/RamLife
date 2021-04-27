import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// A widget to guide the admin in modifying a day in the calendar. 
/// 
/// Creates a pop-up that allows the admin to set the dayName and [Schedule]
/// for a given day in the calendar.
/// 
/// If [day] is provided, then the fields [DayBuilderModel.name],
/// [DayBuilderModel.schedule], are set to [Day.name] and [Day.schedule].
class DayBuilder extends StatefulWidget {
	/// The date this widget is modifying.
	final DateTime date;

	/// The day to edit, if it already exists. 
	final Day? day;

	/// A function to upload the created day to the calendar. 
	final Future<void> Function(Day?) upload;

	/// Creates a widget to guide the user in creating a [Day] 
	const DayBuilder({
		required this.day, 
		required this.date, 
		required this.upload
	});

	@override
	DayBuilderState createState() => DayBuilderState();
}

/// The state for a [DayBuilder]. 
/// 
/// Creates a [DayBuilderModel].
class DayBuilderState extends ModelListener<DayBuilderModel, DayBuilder> {
	@override
	DayBuilderModel getModel() => DayBuilderModel(
		day: widget.day, 
		date: widget.date
	);

	@override
	Widget build(BuildContext context) => AlertDialog(
		title: const Text("Edit day"),
		content: Column (
			mainAxisSize: MainAxisSize.min,
			children: [
				Text("Date: ${widget.date.month}/${widget.date.day}"),
				const SizedBox(height: 20),
				SwitchListTile(
					title: const Text("School?"),
					value: model.hasSchool,
					onChanged: (bool value) => model.hasSchool = value,
				),
				Container(
					width: double.infinity,
					child: Wrap (
						alignment: WrapAlignment.spaceBetween,
						crossAxisAlignment: WrapCrossAlignment.center,
						children: [
							const Text("Day", textAlign: TextAlign.center),
							DropdownButton<String>(
								value: model.name,
								hint: const Text("Day"),
								onChanged: !model.hasSchool ? null : 
									(String? value) => model.name = value,
								items: [
									for (final String dayName in Models.instance.schedule.user.dayNames)
										DropdownMenuItem<String>(
											value: dayName,
											child: Text(dayName),
										)
								],
							)
						]
					),
				),
				const SizedBox(height: 20),
				Container(
					width: double.infinity,
					child: Wrap (
						runSpacing: 3,
						children: [
							const Text("Schedule"),
							DropdownButton<String>(
								value: model.schedule?.name,
								hint: const Text("Schedule"),
								onChanged: !model.hasSchool ? null : (String? value) => 
									model.schedule = Schedule.schedules.firstWhere(
										(Schedule schedule) => schedule.name == value
									),
								items: [
									for (final Schedule schedule in Schedule.schedules) 
										DropdownMenuItem(
											value: schedule.name,
											child: Text(schedule.name),
										),
								],
							)
						]
					)
				)
			]
		),
		actions: [
			TextButton(
				onPressed: () => Navigator.of(context).pop(),
				child: const Text("Cancel"),
			),
			ElevatedButton(
				onPressed: !model.ready ? null : () async {
					await widget.upload(model.day);
					Navigator.of(context).pop();
				},
				child: const Text("Save", style: TextStyle(color: Colors.white)),
			)
		]
	);
}
