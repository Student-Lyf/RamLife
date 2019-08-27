import "package:flutter/foundation.dart";
import "dart:async";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

class Sports with ChangeNotifier {
	static const Duration updateInterval = Duration (hours: 1);

	List<SportsGame> games, recents, upcoming;
	Timer timer;

	Sports(Reader reader) {
		setup(reader);
		timer = Timer.periodic(updateInterval, updateGames);
	}

	@override
	void dispose() {
		timer.cancel();
		super.dispose();
	}

	void setup(Reader reader) {
		games = SportsGame.fromList(reader.sportsData);
		updateGames();
	}

	void updateGames([_]) {
		final DateTime now = DateTime.now();
		recents = [];
		upcoming = [];
		for (final SportsGame game in games) {
			if (game.time < now) recents.add(game);
			else upcoming.add(game);
		}
		notifyListeners();
	}
}
