import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

import "special_builder.dart";

/// A widget to guide the admin in modifying a day in the calendar. 
/// 
/// Creates a pop-up that allows the admin to set the dayName and [Special]
/// for a given day in the calendar, even providing an option to create a custom
/// [Special].
/// 
/// If [day] is provided, then the fields [DayBuilderModel.name],
/// [DayBuilderModel.special], are set to `day.name` ([Day.name]) and 
/// `day.special` ([Day.special]), respectively.  
class DayBuilder extends StatelessWidget {
	/// Returns the [Day] created by this widget. 
	static Future<Day> getDay({
		@required BuildContext context, 
		@required DateTime date,
		@required Day day,
	}) => showDialog<Day>(
		context: context, 
		builder: (_) => DayBuilder(date: date, day: day),
	);

	/// The date to modify. 
	final DateTime date;

	/// The day to edit, if it already exists. 
	final Day day;

	/// Creates a widget to guide the user in creating a [Day] 
	const DayBuilder({
		@required this.date,
		@required this.day,
	});

	@override
	Widget build (BuildContext context) => ModelListener<DayBuilderModel>(
		model: () => DayBuilderModel(day),
		// ignore: sort_child_properties_last
		child: FlatButton(
			onPressed: () => Navigator.of(context).pop(),
			child: const Text("Cancel"),
		),
		builder: (_, DayBuilderModel model, Widget cancel) => AlertDialog(
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
								const Text("Letter", textAlign: TextAlign.center),
								DropdownButton<String>(
									value: model.name,
									hint: const Text("Letter"),
									onChanged: !model.hasSchool ? null : 
										(String value) => model.name = value,
									items: [
										for (final String dayName in Models.schedule.student.schedule.keys)
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
										(Special special) async {
											if (special.name == null && special.periods == null) {
												special = await SpecialBuilder.buildSpecial(context);
											}
											model.special = special;
										},
									items: [
										for (
											final Special special in 
											model.presetSpecials + model.userSpecials
										) DropdownMenuItem<Special>(
											value: special,
											child: Text(special.name),
										),
										DropdownMenuItem<Special>(
											value: const Special(null, null),
											child: SizedBox(
												child: Row(
													children: const [
														Text("Make new schedule"),
														Icon(Icons.add_circle_outline)
													]
												)
											)
										)
									],
								)
							]
						)
					)
				]
			),
			actions: [
				cancel,
				RaisedButton(
					onPressed: !model.ready ? null : () => 
						Navigator.of(context).pop(model.day),
					child: const Text("Save", style: TextStyle(color: Colors.white)),
				)
			]
		),
	);
}
