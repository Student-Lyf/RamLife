import "package:flutter/material.dart";

/// Defines a common interface for [BottomNavigationBar] and [NavigationRail].
/// 
/// This class maps to both [BottomNavigationBarItem] and 
/// [NavigationRailDestination] with an [icon] and [label] property.
@immutable
abstract class NavigationItem extends StatelessWidget {
	/// The icon for this item.
	final Widget icon;

	/// The label for this item.
	/// 
	/// May also be used as semantics and tooltips.
	final String label;

	/// Creates an abstraction for a navigation item.
	const NavigationItem({required this.icon, required this.label});

	/// Generates an item for [BottomNavigationBar].
	BottomNavigationBarItem get bottomNavBar => 
		BottomNavigationBarItem(icon: icon, label: label);

	/// Generates an item for [NavigationRail].
	NavigationRailDestination get navRail => 
		NavigationRailDestination(icon: icon, label: Text(label));

	/// The app bar for this page.
	AppBar get appBar;

	/// The side sheet for this page.
	Widget? get sideSheet => null;

	/// The FAB for this page.
	Widget? get floatingActionButton => null;

	/// The FAB location for this page.
	FloatingActionButtonLocation? get floatingActionButtonLocation => null;
}
