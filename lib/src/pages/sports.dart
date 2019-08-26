// import "package:flutter/material.dart";

// import "package:ramaz/data.dart";
// import "package:ramaz/widgets.dart";

// class SportsPage extends StatelessWidget {
// 	static const List<Tab> tabs = [
// 		Tab(text: "Recent"),
// 		Tab(text: "Upcoming")
// 	];

// 	final List<SportsGame> recent, upcoming;
// 	SportsPage._ (this.recent, this.upcoming);

// 	factory SportsPage(List<SportsGame> games) {
// 		final DateTime now = DateTime.now();
// 		final List<SportsGame> recent = games.where(
// 			(SportsGame game) => game.time < now
// 		).toList();
// 		final List<SportsGame> upcoming = games.where (
// 			(SportsGame game) => game.time > now
// 		).toList();
// 		return SportsPage._(recent, upcoming);
// 	}

// 	@override Widget build(BuildContext context) => DefaultTabController (
// 		length: 2,
// 		child: Scaffold (
// 			appBar: AppBar (
// 				title: Text ("Sports"),
// 				bottom: TabBar (tabs: tabs)
// 			),
// 			// body: TabBarView (
// 			// 	children: tabs.map (
// 			// 		(Tab tab) => ListView (
// 			// 			children: [recent, upcoming].map(
// 			// 				(List<SportsGame> gamesList) => ListView (
// 			// 					children: gamesList.map (
// 			// 						(SportsGame game) => SportsTile (game)
// 			// 					).toList()
// 			// 				)
// 			// 			).toList()
// 			// 		)
// 			// 	).toList()
// 			// )
// 			body: TabBarView (
// 				children: [
// 					ListView (children: recent.map((SportsGame game) => SportsTile(game)).toList()),
// 					ListView (children: upcoming.map((SportsGame game) => SportsTile(game)).toList()),
// 				]
// 			)
// 		)
// 	);

// 	// @override Widget build(BuildContext context) => Scaffold (ListView (
// 	// 	children: recent.map((SportsGame game) => SportsTile(game)).toList()
// 	// );
// }
