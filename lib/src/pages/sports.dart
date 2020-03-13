import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

import "package:url_launcher/url_launcher.dart";

/// A Swipe to Refresh list of [SportsGame]s. 
/// 
/// This is used to simplify the logic between games that are sorted 
/// chronologically and by sport, since both will be split by past and 
/// future games. 
class GenericSportsView<T> extends StatelessWidget {
	/// A list of upcoming games. 
	/// 
	/// This can be any type as long as it can be used in [builder] to build 
	/// [SportsTile]s. 
	final List<T> upcoming;

	/// A list of past games. 
	/// 
	/// This can be any type as long as it can be used in [builder] to build 
	/// [SportsTile]s. 
	final Iterable<T> recents;

	/// Builds a list of [SportsTile]s using [upcoming] and [recents]. 
	final Widget Function(T) builder;

	/// The function to call when the user refreshes the page. 
	final Future<void> Function() onRefresh;

	/// Whether to show a loading indicator. 
	final bool loading;

	/// Creates a list of [SportsTile]s. 
	const GenericSportsView({
		@required this.upcoming,
		@required this.recents, 
		@required this.builder,
		@required this.onRefresh,
		@required this.loading,
	});

	@override
	Widget build(BuildContext context) => TabBarView(
		children: [
			for (final List<T> gamesList in [upcoming, recents])
				RefreshIndicator(
					onRefresh: onRefresh,
					child: ListView(
						children: [
							if (loading)
								const LinearProgressIndicator(),
							for (final T game in gamesList)
								builder(game)
						]
					)
				)
		]
	);
}

/// A page to show recent and upcoming games to the user. 
class SportsPage extends StatelessWidget {
	@override 
	Widget build(BuildContext context) => DefaultTabController(
		length: 2,
		child: ModelListener<Sports>(
			dispose: false,  // used in home page
			model: () => Services.of(context).sports,
			builder: (BuildContext context, Sports model, Widget _) => Scaffold(
				appBar: AppBar(
					title: const Text("Sports"),
					bottom: const TabBar(
						tabs: [
							Tab(text: "Upcoming"),
							Tab(text: "Recent"),
						]
					),
					actions: [
						if (model.isAdmin) 
							IconButton(
								icon: Icon(Icons.add),
								tooltip: "Add a game",
								onPressed: () async {
									final game = await Navigator.of(context)
										.pushNamed(Routes.addSportsGame) as SportsGame;
									model.loading = true;
									await model.addGame(game);
									model.loading = false;
								}
							),
	          PopupMenuButton(
	            icon: Icon(Icons.sort),
	            onSelected: (SortOption option) => model.sortOption = option,
	            itemBuilder: (_) => [
	              const PopupMenuItem(
	                value: SortOption.chronological,
	                child: Text("By date"),
	              ),
	              const PopupMenuItem(
	                value: SortOption.sport,
	                child: Text("By sport"),
	              )
	            ]
	          )
					]
				),
				drawer: NavigationDrawer(),
	      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
				floatingActionButton: FloatingActionButton.extended(
	        label: const Text("Watch livestream"),
	        icon: Icon(Icons.open_in_new),
	        onPressed: () => launch(Urls.sportsLivestream),
	      ),
				body: getLayout(context, model),
			),
		)
	);

	/// Creates a [GenericSportsView] based on the sorting option.
	Widget getLayout(BuildContext context, Sports model) {
		switch(model.sortOption) {
			case SortOption.chronological: 
				return GenericSportsView<SportsGame>(
					loading: model.loading,
					onRefresh: model.refresh,
					recents: model.recents,
					upcoming: model.upcoming,
					builder: (SportsGame game) => SportsTile(
						game, 
						onTap: !model.isAdmin ? null : () => openMenu(context, game)
					),
				);
			case SortOption.sport: 
				return GenericSportsView<MapEntry<Sport, List<SportsGame>>>(
					loading: model.loading,
					onRefresh: model.refresh,
					recents: model.recentBySport.entries.toList(),
					upcoming: model.upcomingBySport.entries.toList(),
					builder: (MapEntry<Sport, List<SportsGame>> entry) => Column(
						children: [
							const SizedBox(height: 15),
							Text(SportsGame.capitalize(entry.key)),
							for (final SportsGame game in entry.value) 
								SportsTile(
									game, 
									onTap: !model.isAdmin ? null : () => openMenu(context, game)
								),
							const SizedBox(height: 20),
						]
					)
				);
		}
		return null;
	}

	/// Opens a menu with options for [game]. 
	/// 
	/// This menu can only be accessed by administrators. 
	void openMenu(BuildContext context, SportsGame game) => showDialog(
		context: context,
		builder: (BuildContext context) => SimpleDialog(
			title: Text(game.description),
			children: [
				SimpleDialogOption(
				  onPressed: () async => Services.of(context).sports.updateGame(
				  	game, 
				  	await SportsScoreUpdater.updateScores(context, game)
			  	),
				  child: const Text("Edit scores", textScaleFactor: 1.2),
				),
				const SizedBox(height: 10),
				SimpleDialogOption(
				  onPressed: () async => Services.of(context).sports.replace(
				  	game, 
				  	await Navigator.of(context).pushNamed(Routes.addSportsGame)
			  	),
				  child: const Text("Edit game", textScaleFactor: 1.2),
				),
				const SizedBox(height: 10),
				SimpleDialogOption(
				  onPressed: () async {
				  	Navigator.of(context).pop();
				  	final bool confirm = await showDialog<bool>(
				  		context: context,
				  		builder: (BuildContext context) => AlertDialog(
				  			title: const Text("Confirm"),
				  			content: const Text("Are you sure you want to delete this game?"),
				  			actions: [
				  				FlatButton(
				  					onPressed: () => Navigator.of(context).pop(false),
				  					child: const Text("Cancel"),
			  					),
			  					RaisedButton(
			  						onPressed: () => Navigator.of(context).pop(true),
			  						child: const Text("Confirm"),
		  						)
				  			]
			  			)
			  		);
			  		if (confirm) {
					  	await Services.of(context).sports.delete(game);
					  }
				  },
				  child: const Text("Remove game", textScaleFactor: 1.2),
				),
			]
		)
	);
}
