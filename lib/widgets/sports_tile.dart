import "package:flutter/material.dart";

import "package:ramaz/data/sports.dart";

class SportsTile extends StatelessWidget {
	final SportsGame game;
	const SportsTile(this.game);

	IconData get icon {
		switch (game.sport) {
			// case 
		}
	}
	@override Widget build (BuildContext context) => Card (
		child: ListTile (
			title: Text (game.info),
			subtitle: Text (game.timestamp),
			leading: Icon (icon)
		)
	);
}