import "package:flutter/material.dart";

import "package:ramaz/data/sports.dart";

import "package:ramaz/widgets/loading_image.dart";

class SportsTile extends StatelessWidget {
	final SportsGame game;
	const SportsTile(this.game);

	String get iconPath {
		switch (game.sport) {
			case Sports.baseball: return "images/baseball.png";
			case Sports.basketball: return "images/basketball.png";
			case Sports.soccer: return "images/soccer.png";
			case Sports.hockey: return "images/hockey.png";
			case Sports.tennis: return "images/tennis.png";
			case Sports.volleyball: return "images/volleyball.png";
		}
		return null;
	}

	@override Widget build (BuildContext context) => Card (
		child: ListTile (
			title: Text (game.info),
			subtitle: Text (game.timestamp),
			leading: CircleAvatar (
				child: LoadingImage (
					iconPath
				)
			)
		)
	);
}