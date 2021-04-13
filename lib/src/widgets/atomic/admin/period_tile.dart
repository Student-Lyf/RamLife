import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

/// A widget to represent a [Period] when creating a [Schedule].
class PeriodTile extends StatelessWidget {
	/// The view model to decide the properties of this period. 
	final ScheduleBuilderModel model;

	/// The times for this period. 
	final Range range;

	/// Allows [range] to be formatted according to the user's locale.
	final TimeOfDay start, end;

	/// The [Activity] for this period. 
	final Activity? activity;

	/// The index of this period in [ScheduleBuilderModel.periods].
	final int index;

	/// Creates a widget to edit a period in a [Schedule].
	PeriodTile({
		required this.model,
		required this.range,
		required this.index,
	}) : 
		activity = null,
		start = range.start.asTimeOfDay,
		end = range.end.asTimeOfDay;

	@override
	Widget build(BuildContext context) => SizedBox(
		height: 55,
		child: Stack (
			children: [
				ListTile(
					subtitle: Text(model.periods [index].name),
					title: Text.rich(
						TextSpan(
							children: [
								WidgetSpan(
									child: InkWell(
										onTap: () async => model.replaceTime(
											index, 
											getRange(
												await showTimePicker(
													context: context,
													initialTime: start,
												) ?? start,
												start: true,
											)
										),
										child: Text(
											start.format(context), 
											style: const TextStyle(color: Colors.blue)
										),
									),
								),
								const TextSpan(text: " -- "),
								WidgetSpan(
									child: InkWell(
										onTap: () async => model.replaceTime(
											index,
											getRange(
												await showTimePicker(
													context: context,
													initialTime: end,
												) ?? end,
												start: false,
											)
										),
										child: Text(
											end.format(context), 
											style: const TextStyle(color: Colors.blue)
										),
									),
								),
							]
						)
					),
				)
			]
		)
	);

	/// Creates a [Range] from a [TimeOfDay]. 
	/// 
	/// [start] determines if the range starts with [time] or not.
	Range getRange(TimeOfDay time, {required bool start}) => Range(
		start ? time.asTime : range.start,
		start ? range.end : time.asTime,
	);
}
