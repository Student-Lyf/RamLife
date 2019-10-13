import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

class SchedulePage extends StatelessWidget {
	// ignore_for_file: prefer_const_constructors_in_immutables
	SchedulePage();

	@override
	Widget build (BuildContext context) => ModelListener<ScheduleModel>(
		model: () => ScheduleModel(services: Services.of(context).services),
		// ignore: sort_child_properties_last
		child: const Footer(), 
		builder: (
			BuildContext context, 
			ScheduleModel model, 
			Widget footer
		) => Scaffold(
			appBar: AppBar (
				title: const Text ("Schedule"),
				actions: [
					if (ModalRoute.of(context).isFirst)
						IconButton (
							icon: Icon (Icons.home),
							onPressed: () => Navigator.of(context)
								.pushReplacementNamed(Routes.home)
						)
				],
			),
			bottomNavigationBar: footer,
			floatingActionButton: Builder (
				builder: (BuildContext context) => FloatingActionButton (
					onPressed: () => viewDay (model, context),
					child: const Icon (Icons.calendar_today),
				)
			),
			drawer: ModalRoute.of(context).isFirst ? NavigationDrawer() : null,
			body: Column (
				children: [
					ListTile (
						title: const Text ("Choose a letter"),
						trailing: DropdownButton<Letters> (
							value: model.day.letter, 
							onChanged: (Letters letter) => model.update(newLetter: letter),
							items: [
								for (final Letters letter in Letters.values)
									DropdownMenuItem(
										value: letter,
										child: Text(lettersToString [letter]),
									)
							]
						)
					),
					ListTile (
						title: const Text ("Choose a schedule"),
						trailing: DropdownButton<Special> (
							value: model.day.special,
							onChanged: (Special special) => model.update(newSpecial: special),
							items: [
								for (final Special special in specials)
									DropdownMenuItem(
										value: special,
										child: Text (special.name),
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
	);

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
