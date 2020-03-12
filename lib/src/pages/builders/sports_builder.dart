import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A list of team names to pick from.
// TODO: move these into a central location. 
const List<String> teams = [
	"Boys Varsity basketball", 
	"Girls Varsity volleyball", 
	"(other teams)"
];

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
class SportsBuilder extends StatefulWidget {
	@override
	SportBuilderState createState() => SportBuilderState();
}

/// The state for a [SportsBuilder].
/// 
/// Needed to keep [opponentController] intact.
/// TODO: convert this into a ViewModel.
class SportBuilderState extends State<SportsBuilder> {
	/// The controller for the [TextField] for the opponent's team name. 
	final TextEditingController opponentController = TextEditingController();

	/// The scores for this game. 
	/// TODO: Make this editable
	Scores scores;

	/// The type of sport being played. 
	Sport sport;

	/// The date this game is being played. 
	DateTime date;

	/// The time the game starts. 
	/// 
	/// This needs to be a [TimeOfDay] since [showTimePicker] works with those. 
	/// See [getTime] for converting a [TimeOfDay] into a [Time].

	TimeOfDay start;

	/// The time the day ends. 
	/// 
	/// This needs to be a [TimeOfDay] since [showTimePicker] works with those. 
	/// See [getTime] for converting a [TimeOfDay] into a [Time].
	TimeOfDay end;

	/// The Ramaz team playing. 
	String team;

	/// Whether this game is being played at home or away. 
	bool away = false;
	
	/// Converts a [TimeOfDay] into a [Time]. 
	/// 
	/// This is useful for converting the output of [showTimePicker] into a 
	/// [Range] for [SportsGame.times].
	Time getTime(TimeOfDay time) => time == null 
		? null : Time(time.hour, time.minute);
	
	/// Whether this game is ready to submit. 
	bool get ready => sport != null &&
		team != null &&
		away != null &&
		date != null &&
		start != null &&
		end != null &&
		opponentController.text.isNotEmpty;
	
	/// The game being created. 
	SportsGame get game => SportsGame(
		date: date,
		home: !away,
		times: Range(getTime(start), getTime(end)),
		team: team ?? "",
		opponent: opponentController.text,
		sport: sport,
		scores: scores,
	);
	
	/// Sets [date] to a date selected by the user. 
	/// 
	/// This needs to be written this way to avoid async problems with `setState`.
	Future<void> setDate() async {
		final DateTime selected = await showDatePicker(
			firstDate: DateTime(2019, 09, 01),
			lastDate: DateTime(2020, 06, 30),
			initialDate: DateTime.now(),
			context: context
		);
		setState(() => date = selected);
	}
	
	@override
	Widget build(BuildContext context) => Scaffold(
		appBar: AppBar(title: const Text("Add game")),
		drawer: NavigationDrawer(),
		body: Form(
			child: ListView(
				padding: const EdgeInsets.all(20),
				children: [
					FormRow(
						"Sport",
						DropdownButtonFormField<Sport>(
							hint: const Text("Choose a sport"),
							value: sport,
							onChanged: (Sport value) => setState(() => sport = value),
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
						DropdownButtonFormField<String>(
							itemHeight: 70,
							hint: const Text("Choose a Team"),
							value: team,
							onChanged: (String value) => setState(() => team = value),
							items: [
								for (final String team in teams)
									DropdownMenuItem<String>(value: team, child: Text(team)),

								DropdownMenuItem<String>(
									value: "", 
									child: SizedBox(
										width: 150, 
										child: Row(
											mainAxisSize: MainAxisSize.min,
											children: const [
												Icon(Icons.add),
												SizedBox(width: 10),
												Text("Add team"),
											]
										)
									)
								)
							]
						),
						sized: true,
					),
					FormRow(
						"Opponent",
						TextField(
							controller: opponentController,
							onChanged: (_) => setState(() {}),
						),
						sized: true,
					),
					FormRow(
						"Away game",
						Checkbox(
							onChanged: (bool value) => setState(() => away = value),
							value: away,
						),
					),
					FormRow.editable(
						title: "Date",
						value: date == null ? null 
							: "${date.month}-${date.day}-${date.year}",
						whenNull: Icons.date_range,
						setNewValue: setDate,
					),
					FormRow.editable(
						title: "Start time",
						value: start?.format(context),
						whenNull: Icons.access_time,
						setNewValue: () async {
							final TimeOfDay newTime = await showTimePicker(
								context: context,
								initialTime: start ?? TimeOfDay.now(),
							);
							setState(() => start = newTime);
						},
					),
					FormRow.editable(
						title: "End time",
						value: end?.format(context),
						whenNull: Icons.access_time,
						setNewValue: () async {
							final TimeOfDay newTime = await showTimePicker(
								context: context,
								initialTime: end ?? TimeOfDay.now(),
							);
							setState(() => end = newTime);
						},
					),
					const SizedBox(height: 10),
					const Text("Tap on the card to change the scores", textScaleFactor: 0.9),
					const SizedBox(height: 20),
					SportsTile(
						game, 
						updateScores: (Scores value) => setState(
							() => scores = value ?? game.scores
						)
					),
					ButtonBar(
						children: [
							FlatButton(
								onPressed: () => Navigator.of(context).pop(),
								child: const Text("Cancel"),
							),
							RaisedButton(
								onPressed: ready ? () => Navigator.of(context).pop(game) : null,
								child: const Text("Save"),
							)
						]
					)
				]
			)
		)
	);
}
