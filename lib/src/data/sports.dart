// TODO: girls/boys
// TODO: get score/finished

import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";

enum Sport {baseball, basketball, hockey, tennis, volleyball, soccer}

const Map<String, Sport> stringToSports = {
	"baseball": Sport.baseball,
	"basketball": Sport.basketball,
	"hockey": Sport.hockey,
	"tennis": Sport.tennis,
	"volleyball": Sport.volleyball,
	"soccer": Sport.soccer,
};

@immutable
class SportsGame {
	static List<SportsGame> fromList(List<Map<String, dynamic>> listJson) => [
		for (final Map<String, dynamic> json in listJson) 
			SportsGame.fromJson(json)
	];

	final SchoolEvent time;
	final Sport sport;

	final bool home;
	final String opponent;

	SportsGame({
		@required this.sport,
		@required this.home,
		@required this.opponent,
		@required this.time
	}) : 
		assert (sport != null, "Sport must not be null"),
		assert (home != null, "Home must not be null"),
		assert (opponent != null, "Opponent must not be null"),
		assert (time != null, "Time must not be null");

	SportsGame.fromJson(Map<String, dynamic> json) :
		sport = stringToSports [json ["sport"]],
		home = json ["home"],
		opponent = json ["opponent"],
		time = SchoolEvent.fromJson (json ["time"]);


	String get timestamp => 
		"${time.start.hour}:"
		"${time.start.minute.toString().padRight(2, "0")}-"
		"${time.end.hour}:"
		"${time.end.minute.toString().padRight(2, "0")}";

	String get info => home ? "$opponent @ Ramaz" : "Ramaz @ $opponent";
}
