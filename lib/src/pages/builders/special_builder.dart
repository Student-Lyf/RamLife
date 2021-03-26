import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// A widget to guide the admin in creating a [Special].
/// 
/// The [Special] doesn't have to be created from scratch, it can be based on
/// an existing [Special] by passing it as a parameter to [SpecialBuilder()]. 
class SpecialBuilder extends StatefulWidget {
	/// Returns the [Special] created by this widget. 
	static Future<Special?> buildSpecial(
		BuildContext context,
		[Special? preset]
	) => showDialog(
		context: context, 
		builder: (_) => SpecialBuilder(preset),
	);

	/// The [Special] to base this [Special] on.
	final Special? preset;

	/// Creates a widget to guide the user in creating a [Special].
	const SpecialBuilder([this.preset]);

	@override
	SpecialBuilderState createState() => SpecialBuilderState();
}

/// A state for a [SpecialBuilder]. 
/// 
/// A state is needed to keep the [TextEditingController] from rebuilding. 
class SpecialBuilderState extends State<SpecialBuilder> {
	/// A controller to hold the name of the [Special]. 
	/// 
	/// This will be preset with the name of [SpecialBuilder.preset].
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
	Widget build(BuildContext context) => ModelListener<SpecialBuilderModel>(
		model: () => SpecialBuilderModel()..usePreset(widget.preset),
		builder: (_, SpecialBuilderModel model, Widget? cancel) => Scaffold(
			appBar: AppBar(
				title: const Text("Make new schedule"),
				actions: [
					IconButton(
						icon: const Icon(Icons.sync),
						tooltip: "Use preset",
						onPressed: () async {
							final Special? special = await showModalBottomSheet<Special?>(
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
										for (final Special special in Special.specials) 
											ListTile(
												title: Text (special.name),
												onTap: () => Navigator.of(context).pop(special),
											),
										const Divider(),
										for (
											final Special special in 
											// only admins can access this scren
											Models.instance.user.admin!.specials  
										) ListTile(
											title: Text (special.name),
											onTap: () => Navigator.of(context).pop(special),
										),
									]
								)
							);
							if (special != null) {
								controller.text = special.name;
								model.usePreset(special);
							}
						}
					),
				]
			),
			floatingActionButton: FloatingActionButton.extended(
				label: const Text("Save"),
				icon: const Icon(Icons.done),
				onPressed: !model.ready ? null : 
					() => Navigator.of(context).pop(model.special),
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
								conflicting = Special.specials.any(
									(Special special) => special.name == value
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
					ListTile(
						title: const Text("Homeroom"),
						trailing: DropdownButton<int>(
							value: model.homeroom,
							onChanged: (int? index) => model.homeroom = index,
							items: [
								const DropdownMenuItem(
									value: null,
									child: Text("None")
								),
								for (int index = 0; index < model.numPeriods; index++) 
									DropdownMenuItem(
										value: index,
										child: Text ("${index + 1}"),
									)
							]
						)
					),
					ListTile(
						title: const Text("Mincha"),
						trailing: DropdownButton<int>(
							value: model.mincha,
							onChanged: (int? index) => model.mincha = index,
							items: [
								const DropdownMenuItem(
									value: null,
									child: Text("None")
								),
								for (int index = 0; index < model.numPeriods; index++) 
									DropdownMenuItem(
										value: index,
										child: Text ("${index + 1}"),
									)
							]
						)
					),
					const SizedBox(height: 20),
					for (int index = 0; index < model.numPeriods; index++)
						PeriodTile(
							model: model,
							range: model.times [index],
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
