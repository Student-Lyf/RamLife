import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
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

/// A menu item for the admin console. 
/// 
/// This widget holds a [label] over a big [icon], and when tapped, will push 
/// a page named [routeName].  
class AdminMenuItem extends StatelessWidget {
	/// The icon to display.
  final IconData icon; 

  /// The label to display.
  final String label;

  /// A description of what this admin option does. 
  final String description;

  /// The name of the route to push when tapped. 
  final String routeName; 

  /// Creates a menu item for the admin console.
  const AdminMenuItem({
  	@required this.icon, 
  	@required this.label, 
    @required this.description,
  	@required this.routeName
	});
  
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    subtitle: Text(description),
    leading: Icon(icon),
    onTap: () => Navigator.of(context).pushNamed(routeName),
  );
}

/// The home page for the admin console. 
/// 
/// This page shows all the options that the user has the scopes to access.
/// It does this using [Auth.claims] and its helper functions.
/// 
/// This widget needs to be stateful because the admin scopes are Futures.
class AdminHomePage extends StatefulWidget {
  @override
  AdminHomePageState createState() => AdminHomePageState();
}

/// State for [AdminHomePage]. 
/// 
/// This state takes care of loading [Auth.isCalendarAdmin] and 
/// [Auth.isSportsAdmin] and then displaying the appropriate [AdminMenuItem]s.
class AdminHomePageState extends State<AdminHomePage> {
  bool _isCalendarAdmin, _isSportsAdmin;

  @override
  void initState() {
    super.initState();
    Auth.isCalendarAdmin.then(
      (bool value) => setState(() => _isCalendarAdmin = value)
    );
    Auth.isSportsAdmin.then(
      (bool value) => setState(() => _isSportsAdmin = value)
    );
  }

	@override
	Widget build(BuildContext context) => AdaptiveScaffold(
		drawer: NavigationDrawer(),
		appBar: AppBar(
      title: const Text("Admin Console"),
      actions: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () =>
            Navigator.of(context).pushReplacementNamed(Routes.home),
        )
      ]
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Choose an admin option",
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(height: 20),
        if (_isCalendarAdmin ?? false) const AdminMenuItem(
          label: "Calendar",
          icon: Icons.today,
          description: "Modify the calendar",
          routeName: Routes.calendar,
        ),
        if (_isCalendarAdmin ?? false) const AdminMenuItem(
        	label: "Schedules",
        	icon: Icons.schedule,
          description: "Manage your custom schedules",
        	routeName: Routes.specials, 
      	),
        if (_isSportsAdmin ?? false) const AdminMenuItem(
          icon: Icons.directions_run,
          label: "Sports",
          description: "Add new sports games and record scores",
          routeName: Routes.sports,
        )
      ]
    )
	);
}
