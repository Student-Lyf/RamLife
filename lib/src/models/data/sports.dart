import "dart:async";

import 'package:flutter/cupertino.dart';
import "package:ramaz/constants.dart" show DayComparison;
import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

import "model.dart";

/// A data model for sports games. 
/// 
/// This class hosts [todayGames], a list of games being played today, 
/// as well as CRUD methods for the database (if permissions allow). 
// ignore: prefer_mixin
class Sports extends Model {
	static const Duration _minute = Duration(minutes: 1);

	/// A timer to refresh [todayGames].
	late Timer timer; 

	/// Helps partition [games] by past and future. 
	DateTime now = DateTime.now();

	/// A list of all the games taking place. 
	List<SportsGame> games = [];

	/// A list of games being played today to be showed on the home screen. 
	List<int> todayGames = [];

	/// Loads data from the device and 
	@override
	Future<void> init() async {
		timer = Timer.periodic(_minute, (_) => todayGames = getTodayGames());
		games = SportsGame.fromList(await Services.instance.database.sports.getAll());
		todayGames = getTodayGames();
		now = DateTime.now();
	}

	/// Returns a list of all the games taking place today.
	/// 
	/// The result should be saved to [todayGames].
	List<int> getTodayGames() {
		List<int> todaygame = [
		for (final MapEntry<int, SportsGame> entry in games.asMap().entries) 
			if (entry.value.date.isSameDay(DateTime.now()))
				entry.key,
	];
	print(games);
	return todaygame;
	}

	/// Adds a game to the database. 
	Future<void> addGame(SportsGame? game) async {
		if (game == null) {
			return;
		}
		game.id=DateTime.now().toString();
		print(game.id);
		games.add(game);
		return saveGames();
	}

	/// Replaces a game with another and saves it to the database.
	/// 
	/// Since [SportsGame] objects are immutable, they cannot be changed in place. 
	/// Instead, they are replaced with a new one. 
	Future<void> replace(int index, SportsGame? newGame) async {
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
	Future<void> saveGames() => Services.instance.database.sports
		.setAll(SportsGame.getJsonList(games));
}