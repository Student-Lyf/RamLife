import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

class HomePage extends StatelessWidget {
	const HomePage();

	@override 
	Widget build (BuildContext context) => ChangeNotifierListener<HomeModel>(
		model: () => HomeModel(Services.of(context).services),
		builder: (BuildContext context, HomeModel model, _) => Scaffold (
			appBar: AppBar (
				title: Text ("Home"),
				actions: [
					if (!model.googleSupport) Builder (
						builder: (BuildContext context) => IconButton (
							icon: Logos.google,
							onPressed: () => model.addGoogleSupport(
								onFailure: () => Scaffold.of(context).showSnackBar(
									SnackBar (
										content: Text ("You need to sign in with your Ramaz email")
									)
								),
								onSuccess: () => Scaffold.of(context).showSnackBar(
									SnackBar (
										content: Text ("Google account linked"),
									),
								),
							),
						),
					),
					if (model.schedule.hasSchool) Builder (
						builder: (BuildContext context) => FlatButton(
							child: Text ("Swipe left for schedule"),
							textColor: Colors.white,
							onPressed: () => Scaffold.of(context).openEndDrawer()
						)
					)
				],
			),
			drawer: NavigationDrawer(),
			endDrawer: !model.schedule.hasSchool ? null : Drawer (
				child: ClassList(
					day: model.schedule.today,
					periods: model.schedule.nextPeriod == null 
						? model.schedule.periods
						: model.schedule.periods.getRange (
							(model.schedule.periodIndex ?? -1) + 1, 
							model.schedule.periods.length
						),
					headerText: model.schedule.period == null 
						? "Today's Schedule" 
						: "Upcoming Classes"
				)
			),
			body: RefreshIndicator (  // so you can refresh the period
				onRefresh: () async => model.schedule.onNewPeriod(),
				child: ListView (
					children: [
						RamazLogos.ram_rectangle,
						Divider(),
						Text (
							model.schedule.hasSchool
								? "Today is a${model.schedule.today.n} "
									"${model.schedule.today.name}"
								: "There is no school today",
							textScaleFactor: 2,
							textAlign: TextAlign.center
						),
						SizedBox (height: 20),
						if (model.schedule.hasSchool) NextClass(
							period: model.schedule.period,
							subject: model.schedule.subjects [model.schedule.period?.id]
						),
						// if school won't be over, show the next class
						if (model.schedule.nextPeriod != null) NextClass (
							next: true,
							period: model.schedule.nextPeriod,
							subject: model.schedule.subjects [model.schedule.nextPeriod?.id]
						),
					]
				)
			)
		)
	);
}
