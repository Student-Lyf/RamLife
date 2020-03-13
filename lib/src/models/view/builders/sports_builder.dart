import "package:flutter/material.dart" show ChangeNotifier, TimeOfDay, showTimePicker;

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

// ignore: prefer_mixin
class SportsBuilderModel with ChangeNotifier {
	Scores _scores;
	Sport _sport;
	DateTime _date;
	TimeOfDay _start, _end;

	String _opponent;

	String _team; 
	bool _away = false;

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

	Future<void> saveGame() {}

	Scores get scores => _scores;
	set scores(Scores value) {
		_scores = value;
		notifyListeners();
	}

	Sport get sport => _sport;
	set sport(Sport value) {
		_sport = value;
		notifyListeners();
	}

	DateTime get date => _date;
	set date(DateTime value) {
		_date = value;
		notifyListeners();
	}

	TimeOfDay get start => _start;
	set start(TimeOfDay value) {
		_start = value;
		notifyListeners();
	}

	TimeOfDay get end => _end;
	set end(TimeOfDay value) {
		_end = value;
		notifyListeners();
	}

	String get team => _team;
	set team(String value) {
		_team = value;
		notifyListeners();
	}

	String get opponent => _opponent;
	set opponent(String value) {
		_opponent = value;
		notifyListeners();
	}

	bool get away => _away;
	set away(bool value) {
		_away = value;
		notifyListeners();
	}
}
