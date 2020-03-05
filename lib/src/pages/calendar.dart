import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A page for admins to modify the calendar in the database. 
class CalendarPage extends StatelessWidget {
	/// The months of the year. 
	/// 
	/// These will be the headers of all the months. 
	static const List<String> months = [
		"January", "February", "March", "April", "May", 
		"June", "July", "August", "September", "October",
		"November", "December"
	];

	/// The days of the week. 
	/// 
	/// This will be used as the labels of the calendar. 
	static const List<String> weekdays = [
		"Sun", "Mon", "Tue", "Wed", "Thur", "Fri", "Sat"
	];

	@override
	Widget build(BuildContext context) => Scaffold(
		appBar: AppBar(title: const Text("Calendar")),
		drawer: NavigationDrawer(),
		body: SingleChildScrollView(
			padding: const EdgeInsets.symmetric(horizontal: 5),
			child: ModelListener<CalendarModel>(
				model: () => CalendarModel(),
				builder: (_, CalendarModel model, __) => ExpansionPanelList.radio(
					children: [
						for (int month = 0; month < 12; month++)
							ExpansionPanelRadio(
								value: month,
								canTapOnHeader: true,
								headerBuilder: (_, __) => ListTile(
									title: Text(months [month]),
									trailing: Text(model.years [month].toString())
								),
								body: model.calendar [month] == null
									? const CircularProgressIndicator()
									: SizedBox(
										height: 350,
										child: GridView.count(
											physics: const NeverScrollableScrollPhysics(),
											shrinkWrap: true,
											crossAxisCount: 7, 
											children: [
												for (final String weekday in weekdays) 
													Center(child: Text (weekday)),
												for (int _ = 0; _ < (model.paddings [month] ?? [0]) [0]; _++)
													CalendarTile.blank,
												for (
													final MapEntry<int, Day> entry in 
													model.calendar [month].asMap().entries
												) GestureDetector(
													onTap: (entry.value?.school ?? false) 
														? () async => model.updateDay(
															DateTime(model.years [month], month + 1, entry.key + 1),
															await DayBuilder.getDay(
																context: context, 
																date: DateTime(model.years [month], month + 1, entry.key + 1),
															)
														) : null,
													child: CalendarTile(
														date: entry?.key,
														day: entry?.value,
													)
												),
												for (int _ = 0; _ < (model.paddings [month] ?? [0]) [1]; _++)
													CalendarTile.blank,
											]
										)
									)
							)
					]
				)
			)
		)
	);
}
