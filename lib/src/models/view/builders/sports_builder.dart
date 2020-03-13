import "package:flutter/material.dart" show ChangeNotifier, TimeOfDay, showTimePicker;

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A ViewModel for the Sports game builder. 
// ignore: prefer_mixin
class SportsBuilderModel with ChangeNotifier {
	Scores _scores;
	Sport _sport;
	DateTime _date;
	TimeOfDay _start, _end;

	String _opponent, _team; 
	bool _away = false, _loading = false;

	/// Converts a [TimeOfDay] into a [Time]. 
	/// 
	/// This is useful for converting the output of [showTimePicker] into a 
	/// [Range] for [SportsGame.times].
	Time getTime(TimeOfDay time) => time == null 
		? null : Time(time.hour, time.minute);

	/// Whether this game is ready to submit. 
	bool get ready => sport != null &&
		team != null &&
		away != null &&
		date != null &&
		start != null &&
		end != null &&
		opponent.isNotEmpty;

	/// The game being created. 
	SportsGame get game => SportsGame(
		date: date,
		home: !away,
		times: Range(getTime(start), getTime(end)),
		team: team ?? "",
		opponent: opponent ?? "",
		sport: sport,
		scores: scores,
	);

	/// Saves the game to the database. 
	/// 
	/// Also triggers the loading animation. See [loading]. See 
	/// [Firestore.saveGame] for how the game is saved. 
	Future<void> saveGame() async {
		loading = true;
		await Firestore.saveGame(game.toJson());
		loading = false;
	}

	/// The scores for this game.
	/// 
	/// This only applies if the game has already been finished.
	/// 
	/// Changing this will update the page.  
	Scores get scores => _scores;
	set scores(Scores value) {
		_scores = value;
		notifyListeners();
	}

	/// The sport being played. 
	/// 
	/// Changing this will update the page. 
	Sport get sport => _sport;
	set sport(Sport value) {
		_sport = value;
		notifyListeners();
	}

	/// The date this game takes place. 
	/// 
	/// Changing this will update the page. 
	DateTime get date => _date;
	set date(DateTime value) {
		_date = value;
		notifyListeners();
	}

	/// The time this game starts. 
	/// 
	/// Changing this will update the page. 
	TimeOfDay get start => _start;
	set start(TimeOfDay value) {
		_start = value;
		notifyListeners();
	}

	/// The time this game ends. 
	/// 
	/// Changing this will update the page. 
	TimeOfDay get end => _end;
	set end(TimeOfDay value) {
		_end = value;
		notifyListeners();
	}

	/// The (home) team playing this game. 
	/// 
	/// Changing this will update the page. 
	String get team => _team;
	set team(String value) {
		_team = value;
		notifyListeners();
	}

	/// The name of the opponent school.
	/// 
	/// Changing this will update the page. 
	String get opponent => _opponent;
	set opponent(String value) {
		_opponent = value;
		notifyListeners();
	}

	/// Whether this game is being played away. 
	/// 
	/// Changing this will update the page. 
	bool get away => _away;
	set away(bool value) {
		_away = value;
		notifyListeners();
	}

	/// Whether the page should display as loading. 
	/// 
	/// The only time this should be changed is on [saveGame].
	bool get loading => _loading;
	set loading(bool value) {
		_loading = value;
		notifyListeners();
	}
}
