import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// A widget to guide the admin in creating a [Schedule].
/// 
/// The [Schedule] doesn't have to be created from scratch, it can be based on
/// an existing schedule by passing it as a parameter to [ScheduleBuilder()]. 
class ScheduleBuilder extends StatefulWidget {
	/// Returns the [Schedule] created by this widget. 
	static Future<Schedule?> buildSchedule(
		BuildContext context,
		[Schedule? preset]
	) => showDialog(
		context: context, 
		builder: (_) => ScheduleBuilder(preset),
	);

	/// The [Schedule] to base this schedule on.
	final Schedule? preset;

	/// Creates a widget to guide the user in creating a schedule.
	const ScheduleBuilder([this.preset]);

	@override
	ScheduleBuilderState createState() => ScheduleBuilderState();
}

/// A state for a [ScheduleBuilder]. 
/// 
/// A state is needed to keep the [TextEditingController] from rebuilding. 
class ScheduleBuilderState extends State<ScheduleBuilder> {
	/// A controller to hold the name of the [Schedule]. 
	/// 
	/// This will be preset with the name of [ScheduleBuilder.preset].
	final TextEditingController controller = TextEditingController();

	/// If the name of the schedule conflicts with another one.
	/// 
	/// Names of custom schedules cannot conflict with the default schedules, since
	/// users will be confused when the app displays a familiar schedule name, but 
	/// updates at unusual times.
	bool conflicting = false;

	@override
	void initState() {
		super.initState();
		controller.text = widget.preset?.name ?? "";
	}

	@override 
	Widget build(BuildContext context) => ModelListener<ScheduleBuilderModel>(
		model: () => ScheduleBuilderModel(widget.preset),
		builder: (_, ScheduleBuilderModel model, Widget? cancel) => Scaffold(
			appBar: AppBar(
				title: const Text("Make new schedule"),
				actions: [
					IconButton(
						icon: const Icon(Icons.sync),
						tooltip: "Use preset",
						onPressed: () async {
							final Schedule? schedule = await showModalBottomSheet<Schedule?>(
								context: context,
								builder: (BuildContext context) => ListView(
									children: [
										const SizedBox(
											width: double.infinity,
											height: 60,
											child: Center(
												child: Text("Use a preset", textScaleFactor: 1.5),
											),
										),
										for (final Schedule schedule in Schedule.schedules) 
											ListTile(
												title: Text (schedule.name),
												onTap: () => Navigator.of(context).pop(schedule),
											),
									]
								)
							);
							if (schedule != null) {
								controller.text = schedule.name;
								model.usePreset(schedule);
							}
						}
					),
				]
			),
			floatingActionButton: FloatingActionButton.extended(
				label: const Text("Save"),
				icon: const Icon(Icons.done),
				onPressed: !model.ready ? null : 
					() => Navigator.of(context).pop(model.schedule),
				backgroundColor: model.ready
					? Theme.of(context).accentColor
					: Theme.of(context).disabledColor,
			),
			body: ListView(
				padding: const EdgeInsets.all(15),
				children: [
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 10),
						child: TextField(
							controller: controller,
							onChanged: (String value) {
								conflicting = Schedule.schedules.any(
									(Schedule other) => other.name == value
								);
								model.name = value;
							},
							textInputAction: TextInputAction.done,
							textCapitalization: TextCapitalization.sentences,
							decoration: InputDecoration(
								labelText: "Name",
								hintText: "Name of the schedule",
								errorText: conflicting 
									? "Name cannot match an existing schedule's name" 
									: null,
							),
						),
					),
					const SizedBox(height: 20),
					for (int index = 0; index < model.numPeriods; index++)
						PeriodTile(
							model: model,
							range: model.periods [index].time,
							index: index,
						),
					Row(
						children: [
							TextButton.icon(
								icon: const Icon (Icons.add),
								label: const Text("Add"),
								onPressed: () => model.numPeriods++,
							),
							if (model.numPeriods > 0) 
								TextButton.icon(
									icon: const Icon(Icons.remove),
									label: const Text("Remove"),
									onPressed: () => model.numPeriods--
								),
						]
					),
					if (model.numPeriods == 0) 
						const Text(
							"You can also select a preset by clicking the button on top",
							textScaleFactor: 1.5,
							textAlign: TextAlign.center,
						),
				]
			)
		)
	);
}
