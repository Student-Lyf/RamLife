import "package:flutter/material.dart";

/// Defines a common interface for [BottomNavigationBar] and [NavigationRail].
/// 
/// This class maps to both [BottomNavigationBarItem] and 
/// [NavigationRailDestination] with an [icon] and [label] property.
abstract class NavigationItem<M extends ChangeNotifier> {
	/// The data model for this page, if any.
	M? model;

	/// Whether this item's data model should be disposed.
	bool shouldDispose;

	/// The icon for this item.
	final Widget icon;

	/// The label for this item.
	/// 
	/// May also be used as semantics and tooltips.
	final String label;

	/// Creates an abstraction for a navigation item.
	NavigationItem({
		required this.icon, 
		required this.label,
		this.model,
		this.shouldDispose = true,
	});

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

	/// The main content on the page. 
	Widget build(BuildContext context);
}
