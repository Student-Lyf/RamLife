import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

class SportsPage extends StatelessWidget {
	static const List<Tab> tabs = [
		Tab(text: "Recent"),
		Tab(text: "Upcoming")
	];

	@override Widget build(BuildContext context) => DefaultTabController (
		length: 2,
		initialIndex: 1,
		child: Scaffold(
			appBar: AppBar(
				title: const Text("Sports"),
				bottom: const TabBar(tabs: tabs),
				actions: [
					IconButton(
						icon: Icon (Icons.home),
						onPressed: () => 
							Navigator.of(context).pushReplacementNamed(Routes.home)
					)
				]
			),
			drawer: NavigationDrawer(),
			body: ModelListener<Sports>(
				model: () => Sports(Services.of(context).reader),
				dispose: false,
				builder: (BuildContext context, Sports model, Widget _) => TabBarView(
					children: [
						for (List<SportsGame> gameList in [model.recents, model.upcoming])
							ListView (
								padding: const EdgeInsets.only(top: 10),
								children: [
									for (final SportsGame game in gameList)
										SportsTile(game)
								]
							)
					]
				),
			),
		)
	);
}
