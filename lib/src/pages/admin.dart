import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/pages.dart";

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

  /// The name of the route to push when tapped. 
  final String routeName; 
  
  /// Creates a menu item for the admin console.
  const AdminMenuItem({
  	@required this.icon, 
  	@required this.label, 
  	@required this.routeName
	});
  
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.of(context).pushReplacementNamed(routeName),
    child: Column(
      children: [
        const SizedBox(height: 10),
        Text(label, textScaleFactor: 1.25),
        const SizedBox(height: 25),
        Icon(icon, size: 100),
      ]
    )
  );
}

/// The home page for the admin console. 
class AdminHomePage extends StatelessWidget {
	@override
	Widget build(BuildContext context) => Scaffold(
		drawer: NavigationDrawer(),
		appBar: AppBar(title: const Text("Admin Console")),
		body: Column(
      children: [
        const SizedBox(height: 10),
        const Text("Select an option", textScaleFactor: 2),
        const SizedBox(height: 25),
        Expanded(
          child: GridView.count(
            childAspectRatio: 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            crossAxisCount: 2,
            children: const [
              AdminMenuItem(
              	icon: Icons.schedule,
              	label: "Manage schedules",
              	routeName: Routes.specials, 
            	),
              AdminMenuItem(
              	icon: Icons.today,
              	label: "Edit calendar",
              	routeName: Routes.calendar,
            	),
            ]
          )
        )
      ]
		),
	);
}
