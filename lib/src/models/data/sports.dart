import "dart:async";

import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// Different ways to sort the sports calendar.
enum SortOption {
	/// Sorts the sports games chronologically.
	/// 
	/// Uses [SportsGame.date].
	chronological, 

	/// Sorts the sports game by sport. 
	/// 
	/// Uses [SportsGame.sport].
	sport
}

/// A view model for the sports page. 
/// 
/// This model is in charge of reading the games from [Reader.sportsData] and
/// sorting them into recent and upcoming, as well as further sorting by sport,
/// if the user chooses. 
// ignore: prefer_mixin
class Sports with ChangeNotifier {
	/// Sorts games by date using [SportsGame.date].
	static int sortByDate(SportsGame a, SportsGame b) => 
		a.date.compareTo(b.date);

	/// Sorts games by their sport.
	/// 
	/// Produces a map where the keys are [SportsGame.sport] and the values are
	/// lists of all the games with that sport. 
	static Map<Sport, List<SportsGame>> sortBySport(List<SportsGame> gamesList) {
		final Map<Sport, List<SportsGame>> result = {};
		for (final SportsGame game in gamesList) {
			if (!result.keys.contains(game.sport)) {
				result [game.sport] = [game];
			} else {
				result [game.sport].add(game);
			}
		}
		// Sort those list chronologically.
		for (final List<SportsGame> gamesList in result.values) {
			gamesList.sort(sortByDate);
		}
		return result;
	}

	static const _minute = Duration(minutes: 1);

	static DateTime _now = DateTime.now();	

	/// Provides access to the file system.
	/// 
	/// A list of sports games is available in [Reader.sportsData].
	final Reader reader;

	/// A function to refresh the list of sports games. 
	final Future<void> Function() refresh;

	/// A timer to refresh the games lists. 
	/// 
	/// This is used to reset the day to the current day. 
	/// It's useful for midnight, when an upcoming game can become a recent game.  
	Timer timer;

	/// A list of all the games taking place.
	List<SportsGame> games;

	/// Games that happened in the past.
	List<SportsGame> recents;

	/// Games that are yet to happen.
	List<SportsGame> upcoming;

	/// A list of games that are being played today.
	/// 
	/// This will be shown on the home screen. 
	List<SportsGame> todayGames; 

	/// Recent games sorted by sport.
	/// 
	/// Generated by calling [sortBySport] with [recents]. 
	Map<Sport, List<SportsGame>> recentBySport;

	/// Upcoming games sorted by sport. 
	/// 
	/// Generated by calling [sortBySport] with [upcoming].
	Map<Sport, List<SportsGame>> upcomingBySport;

	SortOption _sortOption = SortOption.chronological;

	/// Creates a sports view model.
	Sports(this.reader, this.refresh) {
		timer = Timer.periodic(_minute, (_) => setup);
		setup(fromDevice: true);
	}

	@override
	void dispose() {
		timer.cancel();
		super.dispose();
	}

	/// The mode selected for sorting [games]. 
	SortOption get sortOption => _sortOption;
	set sortOption(SortOption value) {
		_sortOption = value;
		sort();
		notifyListeners();
	}

	/// Loads the games from [reader] and sorts them.
	void setup({bool fromDevice = false}) {
		if (fromDevice) {
			games = SportsGame.fromList(reader.sportsData);
		}
		sortByRecentAndUpcoming();
		_now = DateTime.now();
		todayGames = getTodayGames();
		sort();
		notifyListeners();
	}

	/// Returns games from [games] if the game is today.
	/// 
	/// This is used to populate [todayGames].
	List<SportsGame> getTodayGames() => [
		for (final SportsGame game in games) 
			if (
				game.date.year == _now.year && 
				game.date.month == _now.month && 
				game.date.day == _now.day
			) game
	];

	/// Sorts the games by past and future. 
	void sortByRecentAndUpcoming() {
		recents = [];
		upcoming = [];
		final DateTime now = DateTime.now();
		for (final SportsGame game in games) {
			(game.dateTime.isAfter(now) ? upcoming : recents).add(game);
		}
		recents?.sort(sortByDate);
		upcoming?.sort(sortByDate);
	}

	/// Sorts the games based on [sortOption]. 
	void sort() {
		switch (sortOption) {
			case SortOption.chronological: break;
			case SortOption.sport:
				recentBySport = sortBySport(recents);
				upcomingBySport = sortBySport(upcoming);
		}
	}
}
