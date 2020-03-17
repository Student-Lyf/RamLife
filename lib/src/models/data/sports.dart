import "dart:async";

import "package:flutter/foundation.dart";

import "package:ramaz/constants.dart" show DayComparison;
import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A data model for sports games. 
/// 
/// This class hosts [todayGames], a list of games being played today, 
/// as well as CRUD methods for the database (if permissions allow). 
// ignore: prefer_mixin
class Sports with ChangeNotifier {
	static const Duration _minute = Duration(minutes: 1);

	/// Provides access to the file system.
	final Reader reader; 

	/// A timer to refresh [todayGames].
	Timer timer; 

	/// The current day.
	/// 
	/// In [setup] (called every minute), the system date is checked against this
	/// value. If they do not match, [getTodayGames] is called to refresh 
	/// the list [todayGames].
	DateTime now;

	/// A list of all the games taking place. 
	List<SportsGame> games;

	/// A list of games being played today to be showed on the home screen. 
	List<int> todayGames;

	/// Creates a data model for sports games. 
	Sports(this.reader) {
		timer = Timer.periodic(_minute, (_) => todayGames = getTodayGames());
		setup(refresh: true);
	}

	/// Loads data from the device and 
	void setup({bool refresh = false}) {
		if (refresh) {
			games = SportsGame.fromList(reader.sportsData);
			todayGames = getTodayGames();
			now = DateTime.now();
		} else {		
			final DateTime newDate = DateTime.now();
			if (!newDate.isSameDay(now)) {
				todayGames = getTodayGames();
				now = newDate;
			}
		}
		notifyListeners();
	}

	/// Returns a list of all the games taking place today.
	/// 
	/// The result should be saved to [todayGames].
	List<int> getTodayGames() => [
		for (final MapEntry<int, SportsGame> entry in games.asMap().entries) 
			if (entry.value.date.isSameDay(DateTime.now()))
				entry.key,
	];

	/// Adds a game to the database. 
	Future<void> addGame(SportsGame game) async {
		if (game == null) {
			return;
		}
		games.add(game);
		return saveGames();
	}

	/// Replaces a game with another and saves it to the database.
	/// 
	/// Since [SportsGame] objects are immutable, they cannot be changed in place. 
	/// Instead, they are replaced with a new one. 
	Future<void> replace(int index, SportsGame newGame) async {
		if (newGame == null) {
			return;
		}
		games [index] = newGame;
		return saveGames();
	}

	/// Deletes a game from the database.
	Future<void> delete(int index) {
		games.removeAt(index);
		return saveGames();
	}

	/// Saves the games to the database. 
	/// 
	/// Used in any database CRUD methods. 
	Future<void> saveGames() => Firestore.saveGames(SportsGame.getJsonList(games));
}