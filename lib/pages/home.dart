import "package:flutter/material.dart";

import "package:ramaz/widgets/services.dart";

import "package:ramaz/models/home.dart";

// UI
import "package:ramaz/pages/drawer.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";
import "package:ramaz/widgets/class_list.dart";
import "package:ramaz/widgets/next_class.dart";
import "package:ramaz/widgets/icons.dart";

class HomePage extends StatelessWidget {
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
					if (model.school) Builder (
						builder: (BuildContext context) => FlatButton(
							child: Text ("Swipe left for schedule"),
							textColor: Colors.white,
							onPressed: () => Scaffold.of(context).openEndDrawer()
						)
					)
				],
			),
			drawer: NavigationDrawer(),
			endDrawer: !model.school ? null : Drawer (
				child: ClassList(
					noteModel: model.noteModel,
					day: model.today,
					periods: model.nextPeriod == null 
						? model.reader.periods
						: model.reader.periods.getRange (
							(model.reader.periodIndex ?? -1) + 1, model.reader.periods.length
						),
					reader: model.reader,
					headerText: model.period == null 
						? "Today's Schedule" 
						: "Upcoming Classes"
				)
			),
			body: RefreshIndicator (  // so you can refresh the period
				onRefresh: model.updatePeriod,
				child: ListView (
					children: [
						RamazLogos.ram_rectangle,
						Divider(),
						Text (
							model.school
								? "Today is a${model.today.n} ${model.today.name}"
								: "There is no school today",
							textScaleFactor: 2,
							textAlign: TextAlign.center
						),
						SizedBox (height: 20),
						if (model.school) NextClass(model: model),
						// if school won't be over, show the next class
						if (model.nextPeriod != null) NextClass (
							next: true,
							model: model,
						),
					]
				)
			)
		)
	);
}
