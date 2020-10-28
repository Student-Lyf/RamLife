// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A page to allow the user to explore their schedule. 
class SchedulePage extends StatelessWidget {
	/// Lets the user know that they chose an invalid schedule combination. 
	void handleInvalidSchedule(BuildContext context) => Scaffold.of(context)
		.showSnackBar(
			const SnackBar(content: Text("Invalid schedule"))
		);

	@override
	Widget build (BuildContext context) => ModelListener<ScheduleModel>(
		model: () => ScheduleModel(),
		// ignore: sort_child_properties_last
		builder: (
			BuildContext context, 
			ScheduleModel model, 
			Widget _
		) => AdaptiveScaffold(
			appBar: AppBar (
				title: const Text ("Schedule"),
				actions: [
					if (ModalRoute.of(context).isFirst)
						IconButton (
							icon: const Icon(Icons.home),
							onPressed: () => Navigator.of(context)
								.pushReplacementNamed(Routes.home)
						)
				],
			),
			bottomNavigationBar: Footer(),
			floatingActionButton: Builder(
				builder: (BuildContext context) => FloatingActionButton(
					onPressed: () => viewDay (model, context),
					child: const Icon (Icons.calendar_today),
				)
			),
			drawer: ModalRoute.of(context).isFirst ? NavigationDrawer() : null,
			body: Builder(
				builder: (BuildContext context) => Column(
					children: [
						ListTile (
							title: const Text ("Day"),
							trailing: DropdownButton<String> (
								value: model.day.name, 
								onChanged: (String value) => model.update(
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
								onChanged: (Special special) => model.update(
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
						Expanded (child: ClassList(day: model.day)),
					]
				)
			)
		)
	);

	/// Allows the user to select a day in the calendar to view. 
	/// 
	/// If there is no school on that day, a [SnackBar] will be shown. 
	Future<void> viewDay(ScheduleModel model, BuildContext context) async {
		final DateTime selected = await pickDate (
			context: context,
			initialDate: model.date,
		);
		if (selected == null) {
			return;
		}
		try {model.date = selected;}
		on Exception {
			Scaffold.of(context).showSnackBar(
				const SnackBar (
					content: Text ("There is no school on this day")
				)
			);
		}
	}
}
