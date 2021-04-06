import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// A widget to guide the admin in modifying a day in the calendar. 
/// 
/// Creates a pop-up that allows the admin to set the dayName and [Special]
/// for a given day in the calendar.
/// 
/// If [day] is provided, then the fields [DayBuilderModel.name],
/// [DayBuilderModel.special], are set to `day.name` ([Day.name]) and 
/// `day.special` ([Day.special]), respectively.  
class DayBuilder extends StatelessWidget {
	final DateTime date;

	/// The day to edit, if it already exists. 
	final Day? day;

	final Future<void> Function(Day?) upload;

	/// Creates a widget to guide the user in creating a [Day] 
	const DayBuilder({
		required this.day, 
		required this.date, 
		required this.upload
	});

	@override
	Widget build(BuildContext context) => ModelListener<DayBuilderModel>(
		model: () => DayBuilderModel(day: day, date: date),
		// ignore: sort_child_properties_last
		child: TextButton(
			onPressed: () => Navigator.of(context).pop(),
			child: const Text("Cancel"),
		),
		builder: (_, DayBuilderModel model, Widget? cancel) => AlertDialog(
			title: const Text("Edit day"),
			content: Column (
				mainAxisSize: MainAxisSize.min,
				children: [
					Text("Date: ${date.month}/${date.day}"),
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
								DropdownButton<Special>(
									value: 
										(model.presetSpecials + model.userSpecials).contains(model.special)
											? model.special : null,
									hint: const Text("Schedule"),
									onChanged: !model.hasSchool ? null : 
										(Special? special) => model.special = special ?? model.special,
									items: [
										for (
											final Special special in 
											model.presetSpecials + model.userSpecials
										) DropdownMenuItem<Special>(
											value: special,
											child: Text(special.name),
										),
									],
								)
							]
						)
					)
				]
			),
			actions: [
				cancel!,
				ElevatedButton(
					onPressed: !model.ready ? null : () async {
						await upload(model.day);
						Navigator.of(context).pop();
					},
					child: const Text("Save", style: TextStyle(color: Colors.white)),
				)
			]
		),
	);
}
