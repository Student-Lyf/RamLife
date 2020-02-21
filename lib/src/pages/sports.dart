import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

enum SortingOption {chronological, sport}

class SportsPage extends StatelessWidget {
	@override Widget build(BuildContext context) => DefaultTabController (
		length: 2,
		child: Scaffold(
			appBar: AppBar(
				title: const Text("Sports"),
				bottom: const TabBar(
					tabs: [
						Tab(text: "Upcoming"),
						Tab(text: "Recent"),
					]
				),
				actions: [
          PopupMenuButton(
            icon: Icon(Icons.sort),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: SortingOption.chronological,
                child: Text("By date"),
              ),
              const PopupMenuItem(
                value: SortingOption.sport,
                child: Text("By sport"),
              )
            ]
          )
				]
			),
			drawer: NavigationDrawer(),
			floatingActionButton: FloatingActionButton.extended(
        label: const Text("Watch livestream"),
        icon: Icon(Icons.open_in_new),
        onPressed: () {}
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
			body: ModelListener<Sports>(
				model: () => Sports(Services.of(context).reader),
				dispose: false,
				builder: (BuildContext context, Sports model, Widget _) => TabBarView(
					children: [
						for (List<SportsGame> gameList in [model.upcoming, model.recents])
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
