import "package:flutter/material.dart";

import "destination.dart";
import "responsive_builder.dart";

/// A Scaffold that rearranges itself according to the device size. 
/// 
/// Uses [LayoutInfo] to decide key elements of the layout. This class has 
/// two uses: with and without primary navigation items. These are items that
/// would normally be placed in a [BottomNavigationBar]. When primary navigation
/// items are provided, two different drawers are used: with and without the 
/// primary navigation items (to avoid duplication in the UI).
/// 
/// On large screens: show the standard drawer and side sheet
/// On medium screens: show the navigation rail and the side sheet
/// On medium narrow screens: show the navigation rail and hide the side sheet
/// On small screens: show the navigation bar and hide the side sheet 
/// 
/// See the package documentation for how the layout is determined. 
class ResponsiveScaffold extends StatefulWidget {
	/// The app bar. 
	/// 
	/// This does not change with the layout, except for showing a drawer menu.
	final PreferredSizeWidget appBar;

	/// The main body of the scaffold. 
	final Widget body;

	final Widget drawer;

	final Widget? sideSheet;

	final Widget? floatingActionButton;

	final bool enableNavigation;

	const ResponsiveScaffold({
		required this.body,
		required this.appBar,
		required this.drawer,
		this.enableNavigation = false,
		this.sideSheet,
		this.floatingActionButton,
	});

	@override
	ResponsiveScaffoldState createState() => ResponsiveScaffoldState();
}

class ResponsiveScaffoldState extends State<ResponsiveScaffold>{
	late int index;

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		index = getDestinationIndex(context);
	}

	Widget navRail() => NavigationRail(
		selectedIndex: index,
		onDestinationSelected: (value) => destinationCallback(context, value),
		labelType: NavigationRailLabelType.all,
		destinations: [
			for (final destination in destinations) destination.rail
		],
	);

	Widget navBar() => NavigationBar(
		selectedIndex: index,
		onDestinationSelected: (value) => destinationCallback(context, value),
		destinations: [
			for (final destination in destinations) destination.bar
		],
	);

	@override
	Widget build(BuildContext context) => ResponsiveBuilder(
		builder: (context, info, _) {
			switch (info.deviceType) {
				case DeviceType.desktop: return Scaffold(
					appBar: widget.appBar,
					floatingActionButton: widget.floatingActionButton,
					body: Row(
						children: [
							widget.drawer,
							Expanded(child: widget.body),
							widget.sideSheet ?? Container(),
						]
					)
				);
				case DeviceType.tabletLandscape: return Scaffold(
					appBar: widget.appBar,
					floatingActionButton: widget.floatingActionButton,
					drawer: Drawer(child: widget.drawer),
					body: Row(
						children: [
							if (widget.enableNavigation) navRail(),
							Expanded(child: widget.body),
							widget.sideSheet ?? Container(),
						]
					)
				);
				case DeviceType.tabletPortrait: return Scaffold(
					appBar: widget.appBar,
					floatingActionButton: widget.floatingActionButton,
					drawer: Drawer(child: widget.drawer),
					endDrawer: widget.sideSheet == null ? null : Drawer(child: widget.sideSheet!),
					body: Row(
						children: [
							if (widget.enableNavigation) navRail(),
							Expanded(child: widget.body),
						]
					)
				);
				case DeviceType.mobile: return Scaffold(
					appBar: widget.appBar,
					floatingActionButton: widget.floatingActionButton,
					drawer: Drawer(child: widget.drawer),
					endDrawer: widget.sideSheet == null ? null : Drawer(child: widget.sideSheet!),
					bottomNavigationBar: widget.enableNavigation ? navBar() : null,
					body: widget.body,
				);
			}
		}
	);
}

