import "package:flutter/material.dart";
import "package:provider/provider.dart" show Consumer;

// UI
import "package:ramaz/pages/drawer.dart";
import "package:ramaz/models/home.dart" show HomeModel;
import "package:ramaz/widgets/class_list.dart";
import "package:ramaz/widgets/next_class.dart";
import "package:ramaz/widgets/icons.dart";

class HomePage extends StatelessWidget {
	final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
	final UniqueKey drawerKey = UniqueKey();

	@override 
	Widget build (BuildContext context) => Consumer<HomeModel> (
		builder: (BuildContext context, HomeModel model, Widget _) => Scaffold (
			key: scaffoldKey,
			appBar: AppBar (
				title: Text ("Home"),
				actions: [
					if (!model.googleSupport) IconButton (
						icon: Logos.google,
						onPressed: () => model.addGoogleSupport(
							onFailure: () => scaffoldKey.currentState.showSnackBar(
								SnackBar (
									content: Text ("You need to sign in with your Ramaz email")
								)
							),
							onSuccess: () => showDialog (
								context: context,
								builder: (BuildContext context) => AlertDialog(
									title: Text ("Google sign in enabled"),
									content: ListTile (
										title: Text (
											"You can now sign in with your Google account"
										)
									),
									actions: [
										FlatButton (
											child: Text ("OK"),
											onPressed: Navigator.of(context).pop
										)
									]
								)
							)
						)
					),
					if (model.school) FlatButton (
						child: Text ("Swipe left for schedule"),
						textColor: Colors.white,
						onPressed: () => scaffoldKey.currentState.openEndDrawer()
					)
				],
			),
			drawer: NavigationDrawer(model.prefs, key: drawerKey),
			endDrawer: !model.school ? null : Drawer (
				child: ClassList(
					periods: model.nextPeriod == null 
						? model.periods
						: model.periods.getRange (
							(model.periodIndex ?? -1) + 1, model.periods.length
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
						if (model.school)
							NextClass(model.period, model.reader.subjects[model.period?.id]),
						// if school is not over, show the next class
						if (model.nextPeriod != null)  
							NextClass (
								model.nextPeriod, 
								model.reader.subjects[model.nextPeriod?.id], 
								next: true
							),
						// LunchTile (lunch: today.lunch),
					]
				)
			)
		)
	);
}
