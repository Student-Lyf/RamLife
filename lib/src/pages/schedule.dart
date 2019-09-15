import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

class SchedulePage extends StatelessWidget {
	const SchedulePage();

	@override
	Widget build (BuildContext context) => ModelListener<ScheduleModel>(
		model: () => ScheduleModel(services: Services.of(context).services),
		child: Footer(), 
		builder: (BuildContext context, ScheduleModel model, Widget footer) => Scaffold(
			appBar: AppBar (
				title: Text ("Schedule"),
				actions: [
					if (ModalRoute.of(context).isFirst)
						IconButton (
							icon: Icon (Icons.home),
							onPressed: () => Navigator.of(context)
								.pushReplacementNamed("home")
						)
				],
			),
			bottomNavigationBar: footer,
			floatingActionButton: Builder (
				builder: (BuildContext context) => FloatingActionButton (
					child: Icon (Icons.calendar_today),
					onPressed: () => viewDay (model, context)
				)
			),
			drawer: ModalRoute.of(context).isFirst ? NavigationDrawer() : null,
			body: Column (
				children: [
					ListTile (
						title: Text ("Choose a letter"),
						trailing: DropdownButton<Letters> (
							value: model.day.letter, 
							onChanged: (Letters letter) => model.update(newLetter: letter),
							items: [
								for (final Letters letter in Letters.values)
									DropdownMenuItem(
										child: Text(lettersToString [letter]),
										value: letter,
									)
							]
						)
					),
					ListTile (
						title: Text ("Choose a schedule"),
						trailing: DropdownButton<Special> (
							value: model.day.special,
							onChanged: (Special special) => model.update(newSpecial: special),
							items: [
								for (final Special special in specials)
									DropdownMenuItem(
										child: Text (special.name),
										value: special,
									)
							]
						)
					),
					SizedBox (height: 20),
					Divider(),
					SizedBox (height: 20),
					Expanded (child: ClassList(day: model.day)),
				]
			)
		)
	);

	void viewDay(ScheduleModel model, BuildContext context) async {
		final DateTime selected = await pickDate (
			context: context,
			initialDate: model.selectedDay
		);
		if (selected == null) return;
		try {model.date = selected;}
		on ArgumentError {
			Scaffold.of(context).showSnackBar(
				SnackBar (
					content: Text ("There is no school on this day")
				)
			);
		}
	}
}
