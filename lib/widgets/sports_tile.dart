import "package:flutter/material.dart";

import "package:ramaz/data/sports.dart";

import "package:ramaz/widgets/icons.dart";

class SportsTile extends StatelessWidget {
	final SportsGame game;
	const SportsTile(this.game);

	Widget get icon {
		switch (game.sport) {
			case Sports.baseball: return SportsIcons.baseball;
			case Sports.basketball: return SportsIcons.basketball;
			case Sports.soccer: return SportsIcons.soccer;
			case Sports.hockey: return SportsIcons.hockey;
			case Sports.tennis: return SportsIcons.tennis;
			case Sports.volleyball: return SportsIcons.volleyball;
		}
		return null;
	}

	@override Widget build (BuildContext context) => Card (
		child: ListTile (
			title: Text (game.info),
			subtitle: Text (game.timestamp),
			leading: icon
		)
	);
}