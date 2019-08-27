import "package:flutter/foundation.dart" show ChangeNotifier, required;

import "schedule.dart";
import "sports.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";
import "package:ramaz/services_collection.dart";

class HomeModel with ChangeNotifier {
	static const Duration minute = Duration (minutes: 1);

	final Schedule schedule;
	final Sports sports;

	List<SportsGame> games;
	bool googleSupport = true;

	HomeModel (ServicesCollection services) :
		schedule = services.schedule,
		sports = services.sports
	{
		schedule.addListener(notifyListeners);
		sports.addListener(updateSports);
		updateSports();
		checkGoogleSupport();
	}

	@override 
	void dispose() {
		schedule.removeListener(notifyListeners);
		sports.removeListener(updateSports);
		super.dispose();
	}

	void updateSports() {
		final DateTime now = DateTime.now();
		games = sports.games.where(
			(SportsGame game) => (
				game.time.start.year == now.year &&
				game.time.start.month == now.month &&
				game.time.start.day == now.day
			)
		).toList();
		notifyListeners();
	}

	void checkGoogleSupport() async {
		googleSupport = await Auth.supportsGoogle();
		notifyListeners();
	}

	void addGoogleSupport({
		@required void Function() onSuccess,
		@required void Function() onFailure,
	}) async {
		final account = await Auth.signInWithGoogle(onFailure, link: true);
		if (account == null) return;
		googleSupport = true;
		notifyListeners();
		onSuccess();
	}
}
