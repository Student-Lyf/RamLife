import "package:flutter/material.dart";

import "destination.dart";
import "responsive_builder.dart";

/// A Scaffold that rearranges itself according to the device size. 
/// 
/// Mainly, moves elements like [drawer] or [sideSheet] out of the way as the screen gets smaller.
/// Additionally, by setting [enableNavigation] to true, this widget will display [destinations] in
/// the appropriate spot for the screen size. 
/// 
/// This class uses a [LayoutInfo] to decide how to layout the page: 
/// 
/// | Screen Size | Drawer | Side Sheet | Navigation |
/// |--------|--------|--------|--------|
/// | [DeviceType.desktop] | Standard | Standard | [NavigationDrawer] |
/// | [DeviceType.tabletLandscape] | Modal | Standard | [NavigationRail] |
/// | [DeviceType.tabletPortrait] | Modal | Modal | [NavigationRail] |
/// | [DeviceType.desktop] | Modal | Modal | [NavigationBar] |
class ResponsiveScaffold extends StatefulWidget {
	/// The app bar (see [AppBar]).
	final PreferredSizeWidget appBar;

	/// The main body of the scaffold. 
	final Widget body;

	/// The navigation drawer (see [NavigationDrawer]).
	final Widget drawer;

	/// An optional side sheet (see [Scaffold.endDrawer]).
	final Widget? sideSheet;

	/// An optional floating action button (see [FloatingActionButton]).
	final Widget? floatingActionButton;

	/// Whether to show the navigation bar/rail.
	final bool enableNavigation;

	/// Creates a responsive scaffold.
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

/// The state for a [ResponsiveScaffold].
class ResponsiveScaffoldState extends State<ResponsiveScaffold>{
	/// The index of the currently selected [RamLifeDestination].
	late int index;

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		index = getDestinationIndex(context);
	}

	/// A [NavigationRail] of [destinations].
	Widget navRail() => NavigationRail(
		selectedIndex: index,
		onDestinationSelected: (value) => destinationCallback(context, value),
		labelType: NavigationRailLabelType.all,
		destinations: [
			for (final destination in destinations) destination.rail
		],
	);

	/// A [NavigationBar] of [destinations].
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

