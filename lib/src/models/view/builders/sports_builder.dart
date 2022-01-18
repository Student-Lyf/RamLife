import "package:flutter/material.dart" show ChangeNotifier, TimeOfDay;

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";

/// A ViewModel for the Sports game builder. 
// ignore: prefer_mixin
class SportsBuilderModel with ChangeNotifier {
	Scores? _scores;
	Sport? _sport;
	DateTime? _date;
	TimeOfDay? _start, _end;

	String? _opponent, _team, _livestreamUrl;
	bool _away = false, _loading = false;

	/// Creates a ViewModel for the sports game builder page. 
	/// 
	/// Passing in a [SportsGame] for [parent] will fill this page with all the 
	/// relevant properties of [parent] before building. 
	SportsBuilderModel([SportsGame? parent]) : 
		_scores = parent?.scores,
		_sport = parent?.sport,
		_date = parent?.date,
		_start = parent?.times.start.asTimeOfDay,
		_end = parent?.times.end.asTimeOfDay,
		_opponent = parent?.opponent,
		_team = parent?.team,
		_away = !(parent?.isHome ?? true),
		_livestreamUrl = parent?.livestreamUrl;

	/// Whether this game is ready to submit. 
	bool get ready => sport != null &&
		team != null &&
		date != null &&
		start != null &&
		end != null &&
		(opponent?.isNotEmpty ?? false);

	/// The game being created. 
	SportsGame get game => SportsGame(
		date: date!,
		isHome: !away,
		times: Range(start!.asTime, end!.asTime),
		team: team ?? "",
		opponent: opponent ?? "",
		sport: sport!,
		scores: scores,
		livestreamUrl: livestreamUrl,
	);

	/// The scores for this game.
	/// 
	/// This only applies if the game has already been finished.
	/// 
	/// Changing this will update the page.  
	Scores? get scores => _scores;
	set scores(Scores? value) {
		_scores = value;
		notifyListeners();
	}

	/// The sport being played. 
	/// 
	/// Changing this will update the page. 
	Sport? get sport => _sport;
	set sport(Sport? value) {
		_sport = value;
		notifyListeners();
	}

	/// The date this game takes place. 
	/// 
	/// Changing this will update the page. 
	DateTime? get date => _date;
	set date(DateTime? value) {
		_date = value;
		notifyListeners();
	}

	/// The time this game starts. 
	/// 
	/// Changing this will update the page. 
	TimeOfDay? get start => _start;
	set start(TimeOfDay? value) {
		_start = value;
		notifyListeners();
	}

	/// The time this game ends. 
	/// 
	/// Changing this will update the page. 
	TimeOfDay? get end => _end;
	set end(TimeOfDay? value) {
		_end = value;
		notifyListeners();
	}

	/// The (home) team playing this game. 
	/// 
	/// Changing this will update the page. 
	String? get team => _team;
	set team(String? value) {
		_team = value;
		notifyListeners();
	}

	/// The name of the opponent school.
	/// 
	/// Changing this will update the page. 
	String? get opponent => _opponent;
	set opponent(String? value) {
		_opponent = value;
		notifyListeners();
	}

	/// The URL to the livestream for this game
	///
	/// Changing this will update the page.
	String? get livestreamUrl => _livestreamUrl;
	set livestreamUrl(String? value){
		_livestreamUrl = value;
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

	/// Whether the page is loading. 
	bool get loading => _loading;
	set loading(bool value) {
		_loading = value;
		notifyListeners();
	}
}
