import "package:flutter/material.dart";

import "package:ramaz/pages.dart";

class RamLifeDestination {
	final IconData icon;
	final String label;

	const RamLifeDestination({
		required this.icon,
		required this.label,
	});

	NavigationDestination get bar => NavigationDestination(
		icon: Icon(icon),
		label: label,
		tooltip: label,
	);

	NavigationDrawerDestination get drawer => NavigationDrawerDestination(
		icon: Icon(icon),
		label: Text(label),
	);

	NavigationRailDestination get rail => NavigationRailDestination(
		icon: Icon(icon), 
		label: Text(label),
	);
}

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

const destinationRoutes = [
	Routes.home, Routes.schedule, Routes.reminders, Routes.sports,
];

void destinationCallback(BuildContext context, int index) => 
	Navigator.of(context).pushReplacementNamed(destinationRoutes[index]);

int getDestinationIndex(BuildContext context) {
	final name = ModalRoute.of(context)?.settings.name;
	if (name == null) return -1;
	return destinationRoutes.indexOf(name);
}

