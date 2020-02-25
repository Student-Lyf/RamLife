import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";

enum Sport {baseball, basketball, hockey, tennis, volleyball, soccer}

const Map<String, Sport> stringToSport = {
	"baseball": Sport.baseball,
	"basketball": Sport.basketball,
	"hockey": Sport.hockey,
	"tennis": Sport.tennis,
	"volleyball": Sport.volleyball,
	"soccer": Sport.soccer,
};

final Map<Sport, String> sportToString = Map.fromEntries(
	stringToSport.entries.map(
		(MapEntry<String, Sport> entry) => MapEntry(entry.value, entry.key)
	)
);

@immutable
class Scores {
  final int ramazScore, otherScore;
  final bool isHome;
  const Scores(this.ramazScore, this.otherScore, {@required this.isHome});

  Scores.fromJson(Map<String, dynamic> json) : 
  	isHome = json ["isHome"],
  	ramazScore = json ["ramaz"],
  	otherScore = json ["other"];
  
  @override
  String toString() => "Ramaz: $ramazScore, Other: $otherScore";

  bool get didDraw => ramazScore == otherScore;
  bool get didWin => ramazScore > otherScore;

  int getScore({bool home}) => home == isHome 
	  ? ramazScore : otherScore;
}

@immutable
class SportsGame {
	static List<SportsGame> fromList(List<Map<String, dynamic>> listJson) => [
		for (final Map<String, dynamic> json in listJson) 
			SportsGame.fromJson(json)
	];

	final Sport sport;
	final DateTime date;
	final Range times;

	final String team, opponent;
	final bool home;
	final Scores scores;

	const SportsGame({
		@required this.sport,
		@required this.date,
		@required this.times,
		@required this.team,
		@required this.opponent,
		@required this.home,
		this.scores,
	});

	SportsGame.fromJson(Map<String, dynamic> json) :
		sport = stringToSport [json ["sport"]],
		date = DateTime.parse(json ["date"]),
		times = Range.fromJson(json ["times"]),
		team = json ["team"],
		home = json ["home"],
		opponent = json ["opponent"],
		scores = Scores.fromJson(
			Map<String, dynamic>.from(json ["scores"])
		);

	String get homeTeam => home ? "Ramaz" : opponent;
	String get awayTeam => home ? opponent : "Ramaz";
	String get description => "$awayTeam @ $homeTeam";
}
