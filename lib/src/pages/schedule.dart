// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

class ResponsiveSchedule extends NavigationItem {
	final ScheduleModel model = ScheduleModel();

	ResponsiveSchedule() : 
		super(label: "Schedule", icon: const Icon(Icons.schedule));

	/// Allows the user to select a day in the calendar to view. 
	/// 
	/// If there is no school on that day, a [SnackBar] will be shown. 
	Future<void> viewDay(ScheduleModel model, BuildContext context) async {
		final DateTime? selected = await pickDate(
			context: context,
			initialDate: model.date,
		);
		if (selected == null) {
			return;
		}
		try {
			model.date = selected;
		} on Exception {  // user picked a day with no school
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar (
					content: Text ("There is no school on this day")
				)
			);
		}
	}

	@override
	AppBar get appBar => AppBar(title: const Text("Schedule"));

	@override
	Widget? get floatingActionButton => Builder(
		builder: (BuildContext context) => FloatingActionButton(
			onPressed: () => viewDay(model, context),
			child: const Icon(Icons.calendar_today),
		)
	);

	/// Lets the user know that they chose an invalid schedule combination. 
	void handleInvalidSchedule(BuildContext context) => 
		ScaffoldMessenger.of(context).showSnackBar(
			const SnackBar(content: Text("Invalid schedule"))
		);

	@override
	Widget build (BuildContext context) => ModelListener<ScheduleModel>(
		model: () => model,
		dispose: false,
		builder: (_, ScheduleModel model, __) => Column(
			children: [
				ListTile (
					title: const Text ("Day"),
					trailing: DropdownButton<String> (
						value: model.day.name, 
						onChanged: (String? value) => model.update(
							newName: value,
							onInvalidSchedule: () => handleInvalidSchedule(context),
						),
						items: [
							for (final String dayName in Models.instance.schedule.user.dayNames)
								DropdownMenuItem(
									value: dayName,
									child: Text(dayName),
								)
						]
					)
				),
				ListTile (
					title: const Text ("Schedule"),
					trailing: DropdownButton<Special> (
						value: model.day.special,
						onChanged: (Special? special) => model.update(
							newSpecial: special,
							onInvalidSchedule: () => handleInvalidSchedule(context),
						),
						items: [
							for (final Special special in Special.specials)
								DropdownMenuItem(
									value: special,
									child: Text (special.name),
								),
							if (!Special.specials.contains(model.day.special))
								DropdownMenuItem(
									value: model.day.special,
									child: Text(model.day.special.name)
								)
						]
					)
				),
				const SizedBox (height: 20),
				const Divider(),
				const SizedBox (height: 20),
				Expanded(
					child: ClassList(
						day: model.day, 
						periods: Models.instance.user.data.getPeriods(model.day)
					)
				),
			]
		)
	);
}
