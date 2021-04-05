import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
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
	final List<T> recents;

	/// Builds a list of [SportsTile]s using [upcoming] and [recents]. 
	final Widget Function(T) builder;

	/// The function to call when the user refreshes the page. 
	final Future<void> Function() onRefresh;

	/// Whether to show a loading indicator. 
	final bool loading;

	/// Creates a list of [SportsTile]s. 
	const GenericSportsView({
		required this.upcoming,
		required this.recents, 
		required this.builder,
		required this.onRefresh,
		required this.loading,
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

AppBar buildAppBar(SportsModel model) => AppBar(
	title: const Text("Sports"),
	bottom: const TabBar(
		tabs: [
			Tab(text: "Upcoming"),
			Tab(text: "Recent"),
		]
	),
	actions: [
		ModelListener<SportsModel>(
			model: () => model,
			dispose: false,
			builder: (BuildContext context, __, ___) => !model.isAdmin ? Container() 
				: IconButton(
					icon: const Icon(Icons.add),
					tooltip: "Add a game",
					onPressed: model.adminFunc(() async => 
						model.data.addGame(await SportsBuilder.createGame(context))
					),
				),
		),
    PopupMenuButton(
      icon: const Icon(Icons.sort),
      onSelected: (SortOption option) => model.sortOption = option,
      tooltip: "Sort games",
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
    ),
    IconButton(
    	icon: const Icon(Icons.live_tv),
    	onPressed: () => launch(Urls.sportsLivestream),
    	tooltip: "Watch livestream",
  	)
	]
);

/// Creates a [GenericSportsView] based on the sorting option.
Widget getLayout(BuildContext context, SportsModel model) {
	switch(model.sortOption) {
		case SortOption.chronological: 
			return GenericSportsView<int>(
				loading: model.loading,
				onRefresh: model.adminFunc(Services.instance.database.updateSports),
				recents: model.recents,
				upcoming: model.upcoming,
				builder: (int index) => SportsTile(
					model.data.games [index], 
					onTap: !model.isAdmin ? null : () => openMenu(
						context: context,
						index: index,
						model: model,
					)
				),
			);
		case SortOption.sport: 
			return GenericSportsView<MapEntry<Sport, List<int>>>(
				loading: model.loading,
				onRefresh: model.adminFunc(Services.instance.database.updateSports),
				recents: model.recentBySport.entries.toList(),
				upcoming: model.upcomingBySport.entries.toList(),
				builder: (MapEntry<Sport, List<int>> entry) => Column(
					children: [
						const SizedBox(height: 15),
						Text(SportsGame.capitalize(entry.key)),
						for (final int index in entry.value) 
							SportsTile(
								model.data.games [index], 
								onTap: !model.isAdmin ? null : () => openMenu(
									context: context, 
									index: index,
									model: model
								)
							),
						const SizedBox(height: 20),
					]
				)
			);
	}
}

/// Opens a menu with options for the selected game. 
/// 
/// This menu can only be accessed by administrators. 
void openMenu({
	required BuildContext context, 
	required int index, 
	required SportsModel model
}) => showDialog(
	context: context,
	builder: (BuildContext newContext) => SimpleDialog(
		title: Text(model.data.games [index].description),
		children: [
			SimpleDialogOption(
			  onPressed: () async {
			  	Navigator.of(newContext).pop();
			  	final Scores? scores = await SportsScoreUpdater.updateScores(
		  			context, model.data.games [index]
	  			);
			  	if (scores == null) {
			  		return;
			  	}
			  	model.loading = true;
			  	await Models.instance.sports.replace(
				  	index, 
				  	model.data.games [index].replaceScores(scores)
		  		);
			  	model.loading = false;
		  	},
			  child: const Text("Edit scores", textScaleFactor: 1.2),
			),
			const SizedBox(height: 10),
			SimpleDialogOption(
				onPressed: () async {
			  	Navigator.of(newContext).pop();
			  	model.loading = true;
			  	await Models.instance.sports.replace(
				  	index, 
				  	model.data.games [index].replaceScores(null)
		  		);
			  	model.loading = false;
				},
				child: const Text("Remove scores", textScaleFactor: 1.2),
			),
			const SizedBox(height: 10),
			SimpleDialogOption(
			  onPressed: () async {
			  	Navigator.of(newContext).pop();
			  	model.loading = true;
			  	await Models.instance.sports.replace(
				  	index, 
				  	await SportsBuilder.createGame(context, model.data.games [index])
			  	);
			  	model.loading = false;
		  	},
			  child: const Text("Edit game", textScaleFactor: 1.2),
			),
			const SizedBox(height: 10),
			SimpleDialogOption(
			  onPressed: () async {
			  	Navigator.of(newContext).pop();
			  	final bool? confirm = await showDialog(
			  		context: context,
			  		builder: (BuildContext context) => AlertDialog(
			  			title: const Text("Confirm"),
			  			content: const Text("Are you sure you want to delete this game?"),
			  			actions: [
			  				TextButton(
			  					onPressed: () => Navigator.of(context).pop(false),
			  					child: const Text("Cancel"),
		  					),
		  					ElevatedButton(
		  						onPressed: () => Navigator.of(context).pop(true),
		  						child: const Text("Confirm"),
	  						)
			  			]
		  			)
		  		);
		  		if (confirm ?? false) {
		  			model.loading = true;
				  	await Models.instance.sports.delete(index);
		  			model.loading = false;
				  }
			  },
			  child: const Text("Remove game", textScaleFactor: 1.2),
			),
		]
	)
);

/// A page to show recent and upcoming games to the user. 
class SportsPage extends StatelessWidget {
	const SportsPage();

	@override 
	Widget build(BuildContext context) => DefaultTabController(
		length: 2,
		child: ModelListener<SportsModel>(
			model: () => SportsModel(Models.instance.sports),
			builder: (_, SportsModel model, __) => ResponsiveScaffold(
				appBar: buildAppBar(model),
				drawer: const NavigationDrawer(),
				bodyBuilder: (_) => getLayout(context, model),
			),
		)
	);
}
