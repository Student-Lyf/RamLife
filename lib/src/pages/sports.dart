import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

import "package:ramaz/mock.dart";

class SportsPage extends StatelessWidget {
	static const List<Tab> tabs = [
		Tab(text: "Recent"),
		Tab(text: "Upcoming")
	];

	final List<SportsGame> recent, upcoming;
	SportsPage._ (this.recent, this.upcoming);

	factory SportsPage() => SportsPage.fromGames(games);

	factory SportsPage.fromGames(List<SportsGame> games) {
		final DateTime now = DateTime.now();
		final List<SportsGame> recent = games.where(
			(SportsGame game) => game.time < now
		).toList();
		final List<SportsGame> upcoming = games.where (
			(SportsGame game) => game.time > now
		).toList();
		return SportsPage._(recent, upcoming);
	}

	@override Widget build(BuildContext context) => DefaultTabController (
		length: 2,
		initialIndex: 1,
		child: Scaffold (
			appBar: AppBar (
				title: Text ("Sports"),
				bottom: TabBar (tabs: tabs),
				actions: [
					IconButton(
						icon: Icon (Icons.home),
						onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.HOME)
					)
				]
			),
			drawer: NavigationDrawer(),
			body: TabBarView (
				children: [
					for (final List<SportsGame> gameList in [recent, upcoming])
						ListView (
							padding: EdgeInsets.only(top: 10),
							children: [
								for (final SportsGame game in gameList)
									SportsTile(game)
							]
						)
				]
			),
		)
	);
}
