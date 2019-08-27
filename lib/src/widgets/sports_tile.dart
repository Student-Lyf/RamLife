import "package:flutter/material.dart";

import "icons.dart";

import "package:ramaz/data.dart";

class SportsTile extends StatelessWidget {
	final SportsGame game;
	const SportsTile(this.game);

	Widget get icon {
		switch (game.sport) {
			case Sport.baseball: return SportsIcons.baseball;
			case Sport.basketball: return SportsIcons.basketball;
			case Sport.soccer: return SportsIcons.soccer;
			case Sport.hockey: return SportsIcons.hockey;
			case Sport.tennis: return SportsIcons.tennis;
			case Sport.volleyball: return SportsIcons.volleyball;
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
