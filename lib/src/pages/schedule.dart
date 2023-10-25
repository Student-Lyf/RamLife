import "package:flutter/material.dart";
import "package:url_launcher/url_launcher_string.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

import "drawer.dart";

/// Allows users to explore their schedule.
///
/// Users can use the calendar button to check the schedule for a given date
/// or create a custom [Day] from the drop-down menus.
class SchedulePage extends StatelessWidget {
	/// Allows the user to select a day in the calendar to view. 
	/// 
	/// If there is no school on that day, a [SnackBar] will be shown. 
	Future<void> viewDay(ScheduleViewModel model, BuildContext context) async {
		final selected = await pickDate(
			context: context,
			initialDate: model.date,
		);
		if (selected == null) {
			return;
		}
		model.date = selected;
		try {
			model.date = selected;
		} on Exception {  // user picked a day with no school
      if (!context.mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar (
					content: Text ("There is no school on this day"),
				),
			);
		}
	}

  /// Lets the user know that they chose an invalid schedule combination.
  void handleInvalidSchedule(BuildContext context) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Invalid schedule")));

	@override
	Widget build(BuildContext context) => ProviderConsumer(
		create: ScheduleViewModel.new,
		builder: (model, child) => ResponsiveScaffold(
			enableNavigation: true,
			drawer: const RamlifeDrawer(),
			appBar: AppBar(
				title: const Text("Schedule"),
				actions: [ Builder( 
					builder: (BuildContext context) => IconButton(
						icon: const Icon(Icons.search),
						tooltip: "Search schedule",
						onPressed: () => showSearch(
							context: context,
							delegate: CustomSearchDelegate(hintText: "Search for a class"),
						),
					),
				),],
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () => viewDay(model, context),
				child: const Icon(Icons.calendar_today),
			),
			body: Builder(builder: (context) => Column(
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
									),
							],
						),
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
							],
						),
					),
					const Divider(height: 40),
					Expanded(
						child: ClassList(
							day: model.day, 
							periods: Models.instance.user.data.getPeriods(model.day),
						),
					),
				],
			),),
		),
	);
}

/// A class that creates the search bar using ScheduleModel.
class CustomSearchDelegate extends SearchDelegate<Subject> {
	/// This model handles the searching logic.
	final ScheduleSearchModel model = ScheduleSearchModel();

  /// A constructor that constructs the search bar.
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
		child: const Icon(Icons.arrow_back),
	);

  @override
  Widget buildSuggestions(BuildContext context) {
		final subjects = model.getMatchingClasses(query.toLowerCase());

		return ListView(
			children: [
				const SizedBox(height: 15),
				if (subjects.isNotEmpty)
					for (final Subject suggestion in subjects)
						SuggestionWidget(
							suggestion: suggestion,
							onTap: () {
								query = suggestion.name;
								showResults(context);
							},
						)
				else 
					Column(
						children: [ Text(
							"No Results Found",
							style: Theme.of(context).textTheme.headlineMedium,
						),
					],),
			],
		);
	}

  @override
  Widget buildResults(BuildContext context) {
		final subjects = model.getMatchingClasses(query.toLowerCase());

		return ListView(
			children: [
				const SizedBox(height: 15),
				if (subjects.isNotEmpty)
					for (
						final PeriodData period in 
						model.getPeriods(subjects.first)
					)
						ResultWidget(period)
				else 
					Column(
						children: [ Text(
							"No Results Found",
							style: Theme.of(context).textTheme.headlineMedium,
						),
					],),
			],
		);
	}

	@override
	List<Widget> buildActions(BuildContext context) => [
		if (query != "")
			IconButton(
				icon: const Icon(Icons.close),
				onPressed: () => query = "",
			),
	];
}

/// A class that creates each individual suggestion.
class SuggestionWidget extends StatelessWidget {
  /// The function to be run when the suggestion is clicked.
  final VoidCallback onTap;

  /// The Subject given to the widget.
  final Subject suggestion;

	/// A constructor that defines what a suggestion should have.
	const SuggestionWidget({
		required this.suggestion,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) => Column(
		crossAxisAlignment: CrossAxisAlignment.start,
		children: [ InkWell(
			onTap: onTap,
			child: Row(
				children: [ Expanded(
					child: Padding(
						padding: const EdgeInsets.only(left: 20),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [ 
								Text(
									suggestion.name,
									style: Theme.of(context).textTheme.titleMedium,
								),
								const SizedBox(height: 5),
								Text(
									"${suggestion.teacher}   ${suggestion.id}",
									style: Theme.of(context).textTheme.bodySmall,
								),
								const SizedBox(height: 10),
								if (suggestion.virtualLink != null)
									TextButton(
										child: Text(suggestion.virtualLink!),
                    onPressed: () => launchUrlString(suggestion.virtualLink!),
                	),
							],
						),
					),
				),
			],),
		),
		const Divider(
			height: 20,
			indent: 40,
			endIndent: 40,
		),
	],
	);
}

/// A class that creates each individual result.
class ResultWidget extends StatelessWidget {
  /// The PeriodData given to the widget.
  final PeriodData period;

  /// A constructor that defines what a result should have.
  const ResultWidget(this.period);

	@override
	Widget build(BuildContext context) => Column(
		crossAxisAlignment: CrossAxisAlignment.start,
		children: [
			ListTile(
				title: Text(
					"${period.dayName} Period ${period.name}",
						style: Theme.of(context).textTheme.titleMedium,
					),
				subtitle: Text(
					"Room ${period.room}",
					style: Theme.of(context).textTheme.bodySmall,
				),
			),
			for (final reminder in Models.instance.reminders.getReminders(
				dayName: period.dayName,
				period: period.name,
				subject: Models.instance.user.subjects[period.id]?.name,
			))
				Padding(
					padding: const EdgeInsets.only(left: 7),
					child: Row(
						children: [
							const Icon(Icons.notifications),
							const SizedBox(width: 3),
							Text(
								Models.instance.reminders.reminders[reminder].message,
								style: Theme.of(context).textTheme.titleMedium,
							),
						],
					),
				),
			const Divider(height: 20),
		],
	);
}
