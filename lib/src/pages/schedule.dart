// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// Allows users to explore their schedule.
/// 
/// Users can use the calendar button to check the schedule for a given date
/// or create a custom [Day] from the drop-down menus.
class ResponsiveSchedule extends NavigationItem<ScheduleViewModel> {
	@override
	ScheduleViewModel get model => super.model!;

	/// Creates the schedule page.
	ResponsiveSchedule() : super(
		label: "Schedule", 
		icon: const Icon(Icons.schedule),
		model: ScheduleViewModel(),
		shouldDispose: true,
	);

	/// Allows the user to select a day in the calendar to view. 
	/// 
	/// If there is no school on that day, a [SnackBar] will be shown. 
	Future<void> viewDay(ScheduleViewModel model, BuildContext context) async {
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
	void handleInvalidSchedule(BuildContext context) => ScaffoldMessenger
		.of(context)
		.showSnackBar(const SnackBar(content: Text("Invalid schedule")));

	@override
	Widget build(BuildContext context) => Column(
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
				trailing: DropdownButton<Schedule> (
					value: model.day.schedule,
					onChanged: (Schedule? schedule) => model.update(
						newSchedule: schedule,
						onInvalidSchedule: () => handleInvalidSchedule(context),
					),
					items: [
						for (final Schedule schedule in Schedule.schedules)
							DropdownMenuItem(
								value: schedule,
								child: Text (schedule.name),
							),
					]
				)
			),
			ConstrainedBox(
				constraints: const BoxConstraints.tightFor(width: 250),
				child: ElevatedButton(
				onPressed: () => showSearch(
					context: context,
					delegate: CustomSearchDelegate(hintText: "Search for a class")
				),
				child: const ListTile(
					leading:  Icon(Icons.search),
					title: Text("Search for a class")
					)
			),),
			const SizedBox (height: 20),
			const Divider(),
			const SizedBox (height: 20),
			Expanded(
				child: ClassList(
					day: model.day, 
					periods: Models.instance.user.data.getPeriods(model.day)
				),
			),
		]
	);
}

/// A class that creates the search bar using ScheduleModel
class CustomSearchDelegate extends SearchDelegate {
	/// A constructor that constructs the search bar
  CustomSearchDelegate({
    required String hintText,
  }) : super(
    searchFieldLabel: hintText,
    keyboardType: TextInputType.text,
    textInputAction: TextInputAction.search,
  );

  @override
  Widget buildLeading(BuildContext context) => ElevatedButton(
  	onPressed: () => Navigator.of(context).pop(),
  	child: const Icon(Icons.arrow_back)
  );

  @override
  Widget buildSuggestions(BuildContext context) => Column(
  	children: [
  		const SizedBox(height: 15),
  		for (int i=0; i < 5; i++) 
		  	Column(
		  		children: [ 
		  			ListTile(
			  			onTap: () {
			  				query = "Algebra & Trig 7";
			  				showResults(context);
			  			},
			  			title: Text(
			  				"Algebra & Trig 7",
			  					style: Theme.of(context).textTheme.headline4
			  				),
			  			subtitle: Text(
			  				"Rodger Jaffe   102004-10",
			  				style: Theme.of(context).textTheme.headline6
			  			)
			  		),
			  		const SizedBox(height: 10),
			  		const Divider(),
			  		const SizedBox(height: 10),
			  ]
			)
  	]
  );

  @override
  Widget buildResults(BuildContext context) => Column(
  	children: [
  		const SizedBox(height: 15),
  		for (int i=0; i < 5; i++) 
		  	Column(
		  		children: [ 
		  			ListTile(
			  			title: Text(
			  				"Monday",
			  					style: Theme.of(context).textTheme.headline4
			  				),
			  			subtitle: Text(
			  				"Period 2   1:00-2:00",
			  				style: Theme.of(context).textTheme.headline6
			  			)
			  		),
			  		const SizedBox(height: 10),
			  		const Divider(),
			  		const SizedBox(height: 10),
			  ]
			)
  	]
  );

  @override
  List<Widget> buildActions(BuildContext context) => [
  	if (query != "")
  		IconButton(
  			icon: const Icon(Icons.highlight_off),
  			onPressed: () => query = ""
  		)
  ];
}
