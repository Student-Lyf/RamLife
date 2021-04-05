import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A widget to represent a calendar icon.
/// 
/// Due to "budget cuts", poor Levi Lesches ('21) had to recreate the calendar 
/// icon from scratch, instead of Googling for a png. What a loser. 
/// 
/// This widget is not used, rather left here as a token of appreciation for
/// all the time Levi has wasted designing (and scrapping said designs)
/// the UI and backend code for this app. That dude deserves a raise.
class OldCalendarWidget extends StatelessWidget {
	/// Creates a widget to look like the calendar icon. 
	const OldCalendarWidget();

  @override
  Widget build(BuildContext context) => InkWell(
  	onTap: () => Navigator.pushReplacementNamed(context, Routes.calendar),
  	child: Container(
	    decoration: BoxDecoration(border: Border.all()),
	    padding: const EdgeInsets.symmetric(horizontal: 25),
	    child: Column(
	      mainAxisAlignment: MainAxisAlignment.center,
	      crossAxisAlignment: CrossAxisAlignment.center,
	      children: [
	        const Spacer(flex: 1),
	        Expanded(
	          flex: 1,
	          child: Container(
	            decoration: BoxDecoration(border: Border.all()),
	            child: const Center(
	              child: Text("Monday")
	            ),
	          ),
	        ),
	        Expanded(
	          flex: 4,
	          child: Container(
	            decoration: BoxDecoration(border: Border.all()),
	            child: const Center(
	              child: Text("01", textScaleFactor: 2),
	            )
	          )
	        ),
	        const Spacer(flex: 1),
	      ]
	    )
    )
  );
}

/// A page for admins to modify the calendar in the database. 
class AdminCalendarPage extends StatelessWidget {
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

	/// Creates a page for admins to modify the calendar.
	const AdminCalendarPage();

	@override
	Widget build(BuildContext context) => ResponsiveScaffold(
		drawer: const NavigationDrawer(),
		appBar: AppBar(title: const Text("Calendar")),
		bodyBuilder: (_) => SingleChildScrollView(
			padding: const EdgeInsets.symmetric(horizontal: 5),
			child: ModelListener<CalendarEditor>(
				model: () => CalendarEditor(),
				builder: (_, CalendarEditor model, __) => ExpansionPanelList.radio(
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
										height: 400,
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
													final MapEntry<int, Day?> entry in 
													// ExpansionPanelRadio.body checks for nulls
													model.calendar [month]!.asMap().entries
												) GestureDetector(
													onTap: () async => model.updateDay(
														DateTime(model.years [month], month + 1, entry.key + 1),
														await DayBuilder.getDay(
															context: context, 
															date: DateTime(model.years [month], month + 1, entry.key + 1),
															day: entry.value,
														)
													),
													child: CalendarTile(
														date: entry.key,
														day: entry.value,
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
