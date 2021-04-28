import "package:flutter/material.dart";

import "navigation_item.dart";
import "responsive_builder.dart";
 
/// A Scaffold that rearranges itself according to the device size. 
/// 
/// Uses [LayoutInfo] to decide key elements of the layout. This class has 
/// two uses: with and without primary navigation items. These are items that
/// would normally be placed in a [BottomNavigationBar]. When primary navigation
/// items are provided, two different drawers are used: with and without the 
/// primary navigation items (to avoid duplication in the UI).
/// 
/// See the package documentation for how the layout is determined. 
class ResponsiveScaffold extends StatefulWidget {
	/// The app bar. 
	/// 
	/// This does not change with the layout, except for showing a drawer menu.
	final PreferredSizeWidget appBar;

	/// The main body of the scaffold. 
	final WidgetBuilder bodyBuilder;

	/// The full drawer to show. 
	/// 
	/// When there are primary navigation items, it is recommended not to include 
	/// them in the drawer, as that may confuse your users. Instead, provide two 
	/// drawers, one with them and the other, without. 
	/// 
	/// This field should include all navigation items, whereas [secondaryDrawer] 
	/// should exclude all navigation items that are in [navItems]. 
	final Widget drawer;

	/// The secondary, more compact, navigation drawer. 
	/// 	
	/// When there are primary navigation items, it is recommended not to include 
	/// them in the drawer, as that may confuse your users. Instead, provide two 
	/// drawers, one with them and the other, without. 
	/// 
	/// This field should exclude all navigation items that are in [navItems], 
	/// whereas [drawer] should include them. 
	final Widget? secondaryDrawer;

	/// The [side sheet](https://material.io/components/sheets-side).
	/// 
	/// On larger screens (tablets and desktops), this will be a standard 
	/// (persistent) side sheet. On smaller screens, this will be modal. 
	/// 
	/// See [LayoutInfo.hasStandardSideSheet].
	final Widget? sideSheet;

	/// The [Floating Action Button](https://material.io/components/buttons-floating-action-button). 
	/// 
	/// Currently, the position does not change based on layout.
	final Widget? floatingActionButton;

	/// The location of the floating action button. 
	final FloatingActionButtonLocation? floatingActionButtonLocation;

	/// The navigation items. 
	/// 
	/// On phones, these will be in a [BottomNavigationBar]. On tablets, these 
	/// will be in a [NavigationRail]. On desktops, these should be included in 
	/// [drawer] instead. 
	/// 
	/// On phones and tablets, so that the items do not appear twice, provide a 
	/// [secondaryDrawer] that does not include these items.  
	final List<NavigationItem>? navItems;

	/// The initial index of the current navigation item in [navItems].
	final int? initialNavIndex;

	/// Creates a scaffold that responds to the screen size. 
	const ResponsiveScaffold({
		required this.drawer, 
		required this.bodyBuilder,
		required this.appBar,
		this.floatingActionButton,
		this.sideSheet,
		this.floatingActionButtonLocation,
	}) : 
		secondaryDrawer = null,
		navItems = null,
		initialNavIndex = null;

	/// Creates a responsive layout with primary navigation items. 
	ResponsiveScaffold.navBar({
		required this.drawer,
		required this.secondaryDrawer,
		required List<NavigationItem> this.navItems,
		required int this.initialNavIndex,
	}) :
		appBar = navItems [initialNavIndex].appBar,
		bodyBuilder = navItems [initialNavIndex].build,
		floatingActionButton = navItems [initialNavIndex].floatingActionButton,
		floatingActionButtonLocation = navItems [initialNavIndex]
			.floatingActionButtonLocation,
		sideSheet = navItems [initialNavIndex].sideSheet;

	/// Whether this widget is being used with a navigation bar. 
	bool get hasNavBar => navItems != null;

	@override
	ResponsiveScaffoldState createState() => ResponsiveScaffoldState();
}

/// The state of the scaffold. 
class ResponsiveScaffoldState extends State<ResponsiveScaffold> {
	late int _navIndex;
	
	/// The index of the current navigation item in [ResponsiveScaffold.navItems].
	int get navIndex => _navIndex;
	set navIndex(int value) {
		_dispose(navItem);
		_navIndex = value;
		_listen(navItem);
		setState(() {});
	}

	/// The currently selected navigation item, if any.
	NavigationItem? get navItem => !widget.hasNavBar ? null 
		: widget.navItems! [navIndex];

	/// Refreshes the page when the underlying data changes. 
	void listener() => setState(() {});

	void _listen(NavigationItem? item) => item?.model?.addListener(listener);
	void _dispose(NavigationItem? item) {
		if (item != null) {
			item.model?.removeListener(listener);
			if (item.shouldDispose) {
				item.model?.dispose();
			}
		}
	}

	@override
	void initState() {
		super.initState();
		_navIndex = widget.initialNavIndex ?? 0;
		_listen(navItem);
	}

	@override
	void dispose() {
		_dispose(navItem);
		super.dispose();
	}

	@override
	Widget build(BuildContext context) => ResponsiveBuilder(
		child: widget.bodyBuilder(context),  // ignore: sort_child_properties_last
		builder: (BuildContext context, LayoutInfo info, Widget? child) => Scaffold(
			appBar: widget.appBar,
			drawer: info.hasStandardDrawer ? null 
				: Drawer(child: widget.hasNavBar ? widget.secondaryDrawer : widget.drawer),
			endDrawer: info.hasStandardSideSheet || widget.sideSheet == null 
				? null : Drawer(child: widget.sideSheet),
			floatingActionButton: widget.floatingActionButton,
			floatingActionButtonLocation: widget.floatingActionButtonLocation,
			bottomNavigationBar: !widget.hasNavBar || !info.hasBottomNavBar 
				? null 
				: BottomNavigationBar(
					type: BottomNavigationBarType.fixed,
					items: [
						for (final NavigationItem item in widget.navItems!)
							item.bottomNavBar,
					],
					currentIndex: navIndex,
					onTap: (int index) => navIndex = index,
				),
			body: Row(
				children: [
					if (widget.hasNavBar && info.hasNavRail) NavigationRail(
						labelType: NavigationRailLabelType.all,
						destinations: [
							for (final NavigationItem item in widget.navItems!)
								item.navRail,
						],		
						selectedIndex: navIndex,
						onDestinationSelected: (int index) => navIndex = index,
					)
					else if (info.hasStandardDrawer) widget.drawer,
					Expanded(child: child!),
					if (widget.sideSheet != null && info.hasStandardSideSheet) ...[
						const VerticalDivider(),
						SizedBox(
							width: 320,
							child: Drawer(elevation: 0, child: widget.sideSheet),
						)
					]
				]
			)
		),
	);
}
