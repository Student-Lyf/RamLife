import "package:flutter/material.dart";

import "package:ramaz/data/sports.dart";

class SportsTile extends StatelessWidget {
	final SportsGame game;
	const SportsTile(this.game);

	String get iconPath {
		switch (game.sport) {
			case Sports.baseball: return "images/baseball.png";
		}
	}
	@override Widget build (BuildContext context) => Card (
		child: ListTile (
			title: Text (game.info),
			subtitle: Text (game.timestamp),
			leading: Icon (iconPath)
		)
	);
}