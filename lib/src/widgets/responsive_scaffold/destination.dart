import "package:flutter/material.dart";

import "package:ramaz/pages.dart";

/// Serves as a common interface between all sorts of navigation destinations.
class RamLifeDestination {
	/// The icon for this destination.
	final IconData icon;

	/// The label for this destination.
	final String label;

	/// Creates a wrapper for a navigation destination.
	const RamLifeDestination({
		required this.icon,
		required this.label,
	});

	/// This destination as a [NavigationDestination] for a [NavigationBar].
	NavigationDestination get bar => NavigationDestination(
		icon: Icon(icon),
		label: label,
		tooltip: label,
	);

	/// This destination as a [NavigationDrawerDestination] for a [NavigationDrawer].
	NavigationDrawerDestination get drawer => NavigationDrawerDestination(
		icon: Icon(icon),
		label: Text(label),
	);

	/// This destination as a [NavigationRailDestination] for a [NavigationRail].
	NavigationRailDestination get rail => NavigationRailDestination(
		icon: Icon(icon), 
		label: Text(label),
	);
}

/// All the possible destinations in this app.
const destinations = [
	RamLifeDestination(
		icon: Icons.dashboard,
		label: "Dashboard", 
	),
	RamLifeDestination(
		icon: Icons.schedule,
		label: "Schedule", 
	),
	RamLifeDestination(
		icon: Icons.notifications,
		label: "Reminders", 
	),
	RamLifeDestination(
		icon: Icons.sports,
		label: "Sports", 
	),
];

/// All the [Routes] in this app.
const destinationRoutes = [
	Routes.home, Routes.schedule, Routes.reminders, Routes.sports,
];

/// Function to call when a destination is selected.
void destinationCallback(BuildContext context, int index) => 
	Navigator.of(context).pushReplacementNamed(destinationRoutes[index]);

/// Determines the index of our current destination.
/// 
/// If the user is not on one of the pages in [destinationRoutes], then return -1.
int getDestinationIndex(BuildContext context) {
	final name = ModalRoute.of(context)?.settings.name;
	if (name == null) return -1;
	return destinationRoutes.indexOf(name);
}
