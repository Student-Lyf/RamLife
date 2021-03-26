// import "package:flutter/material.dart";

// class AdaptiveScaffold extends StatelessWidget {
// 	static const double largeScreenWidth = 768;
// 	static const double drawerWidth = 256;
// 	// static const double drawerWidth = 320;	
// 	static const double endDrawerWidth = 320;

// 	final Widget body;
// 	final Widget drawer;
// 	final Widget endDrawer;
// 	final Widget floatingActionButton;
// 	final Widget bottomNavigationBar;
// 	final AppBar appBar;
// 	final AppBar Function(bool) appBarBuilder;

// 	const AdaptiveScaffold({
// 		@required this.body,
// 		this.appBar,
// 		this.appBarBuilder,
// 		this.drawer,
// 		this.endDrawer, 
// 		this.floatingActionButton,
// 		this.bottomNavigationBar,
// 	});

// 	@override
// 	Widget build(BuildContext context) {
// 		final double width = MediaQuery.of(context).size.width;
// 		final bool shouldShowDrawer = 
// 			width >= largeScreenWidth + drawerWidth && drawer != null;
// 		final bool shouldShowEndDrawer = width >= 
// 			largeScreenWidth + (drawer == null ? 0 : drawerWidth) + endDrawerWidth
// 			&& endDrawer != null;
// 		final AppBar appBar = this.appBar ?? appBarBuilder(shouldShowEndDrawer);

// 		return Scaffold(
// 			drawer: shouldShowDrawer ? null : drawer,
// 			endDrawer: shouldShowEndDrawer ? null : endDrawer,
// 			appBar: appBar,
// 			floatingActionButton: floatingActionButton,
// 			bottomNavigationBar: bottomNavigationBar,
// 			body: !shouldShowDrawer
// 				? body 
// 				: StandardDrawerBody(
// 						appBar: appBar,
// 						drawer: drawer, 
// 						endDrawer: shouldShowEndDrawer ? null : endDrawer,
// 						body: !shouldShowEndDrawer 
// 							? body
// 							: StandardEndDrawerBody(
// 									body: body, 
// 									endDrawer: endDrawer,
// 								)
// 					)
// 		);
// 	}
// }

// class StandardEndDrawerBody extends StatelessWidget {
// 	final Widget body;
// 	final Widget endDrawer;

// 	const StandardEndDrawerBody({
// 		@required this.body,
// 		@required this.endDrawer,
// 	});

// 	@override
// 	Widget build(BuildContext context) => Row(
// 		children: [
// 			Expanded(child: body),
// 			Container(
// 				width: AdaptiveScaffold.endDrawerWidth,
// 				child: endDrawer, 
// 			)
// 		]
// 	);
// }

// class StandardDrawerBody extends StatelessWidget {
// 	final Widget body;
// 	final Widget drawer;
// 	final AppBar appBar;
// 	final Widget endDrawer;

// 	const StandardDrawerBody({
// 		@required this.body,
// 		@required this.drawer, 
// 		@required this.appBar,
// 		@required this.endDrawer,
// 	});

// 	@override
// 	Widget build(BuildContext context) => Row(
// 		mainAxisSize: MainAxisSize.min,
// 		children: [
// 	    Container(
// 			  width: AdaptiveScaffold.drawerWidth,
// 			  child: Drawer(elevation: 0, child: drawer)
// 			),
// 			Flexible(
// 			  fit: FlexFit.loose,
// 			  child: body,
// 		  ),
// 		]
// 	);
// }

