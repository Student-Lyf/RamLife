import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// A row in a form. 
/// 
/// Displays a title or header on the left, and a picker on the right.
class FormRow extends StatelessWidget {
	/// The title to show. 
	final String title;

	/// The picker for user input. 
	final Widget picker;

	/// Whether to constrict [picker]'s size. 
	final bool sized;

	/// Whether this widget needs more space on the bottom. 
	/// 
	/// Widgets that use [sized] don't need this, since their [picker] is big
	/// enough to provide padding on the bottom as well. Hence, this is only 
	/// set to true for widgets created with [FormRow.editable()], since those
	/// never use a big [picker].
	final bool moreSpace;

	/// Creates a row in a form.
	const FormRow(this.title, this.picker, {this.sized = false}) : 
		moreSpace = false;

	/// A [FormRow] where the right side is represented by an [Icon]  
	/// 
	/// When [value] is null, [whenNull] is displayed. Otherwise, [value] is 
	/// displayed in a [Text] widget. Both widgets, when tapped, call 
	/// [setNewValue].
	FormRow.editable({
		@required this.title,
		@required String value,
		@required VoidCallback setNewValue,
		@required IconData whenNull,
	}) : 
		sized = false,
		moreSpace = true,
		picker = value == null
			? IconButton(
				icon: Icon(whenNull),
				onPressed: setNewValue
			)
			: InkWell(
				onTap: setNewValue,
				child: Text(
					value,
					style: TextStyle(color: Colors.blue),
				),
			);

	@override
	Widget build(BuildContext context) => Column(
		children: [
			Row(
				mainAxisAlignment: MainAxisAlignment.spaceEvenly,
				children: [
					Text(title), 
					const Spacer(), 
					if (sized) Container(
						constraints: const BoxConstraints(
							maxWidth: 200, 
							maxHeight: 75,
						),
						child: picker,
					)
					else picker
				]
			),
			SizedBox(height: moreSpace ? 25 : 15),
		]
	);
}

/// A page to create a Sports game. 
class SportsBuilder extends StatelessWidget {
	@override
	Widget build(BuildContext context) => Scaffold(
		appBar: AppBar(title: const Text("Add game")),
		body: ModelListener<SportsBuilderModel>(
			model: () => SportsBuilderModel(),
			builder: (_, SportsBuilderModel model, __) => ListView(
				padding: const EdgeInsets.all(20),
				children: [
					FormRow(
						"Sport",
						DropdownButtonFormField<Sport>(
							hint: const Text("Choose a sport"),
							value: model.sport,
							onChanged: (Sport value) => model.sport = value,
							items: [
								for (final Sport sport in Sport.values) 
									DropdownMenuItem<Sport>(
										value: sport,
										child: Text(sport.toString().split(".") [1])
									)
							],
						),
						sized: true,
					),
					FormRow(
						"Team",
						TextField(
							onChanged: (String value) => model.team = value,
						),
						sized: true,
					),
					FormRow(
						"Opponent",
						TextField(
							onChanged: (String value) => model.opponent = value,
						),
						sized: true,
					),
					FormRow(
						"Away game",
						Checkbox(
							value: model.away,
							onChanged: (bool value) => model.away = value,
						),
					),
					FormRow.editable(
						title: "Date",
						value: SportsTile.formatDate(model.date, noNull: true),
						whenNull: Icons.date_range,
						setNewValue: () async => model.date = await pickDate(
							initialDate: DateTime.now(),
							context: context
						),
					),
					FormRow.editable(
						title: "Start time",
						value: model.start?.format(context),
						whenNull: Icons.access_time,
						setNewValue: () async => model.start = await showTimePicker(
							context: context,
							initialTime: model.start ?? TimeOfDay.now(),
						),
					),
					FormRow.editable(
						title: "End time",
						value: model.end?.format(context),
						whenNull: Icons.access_time,
						setNewValue: () async => model.end = await showTimePicker(
							context: context,
							initialTime: model.end ?? TimeOfDay.now(),
						),
					),
					const SizedBox(height: 10),
					const Text("Tap on the card to change the scores", textScaleFactor: 0.9),
					const SizedBox(height: 20),
					SportsTile(
						model.game,
						updateScores: (Scores value) => 
							model.scores = value ?? model.scores
					),
					ButtonBar(
						children: [
							FlatButton(
								onPressed: () => Navigator.of(context).pop(),
								child: const Text("Cancel"),
							),
							RaisedButton(
								onPressed: model.ready ? model.saveGame : null,
								child: const Text("Save"),
							)
						]
					)
				]
			)
		)
	);
}
