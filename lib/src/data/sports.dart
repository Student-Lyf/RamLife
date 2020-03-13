import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";

/// All the different sports that can be played. 
/// 
// TODO(Levi): move this into somewhere it's not hard-coded, #1
enum Sport {
	/// Baseball. 
	baseball, 

	/// Basketball.
	basketball, 

	/// Hockey.
	hockey, 

	/// Tennis.
	tennis, 

	/// Volleyball.
	volleyball, 

	/// Soccer.
	soccer
}

/// Converts Strings to [Sport] values.
/// 
/// Use this on JSON values, since they can only use Strings.  
const Map<String, Sport> stringToSport = {
	"baseball": Sport.baseball,
	"basketball": Sport.basketball,
	"hockey": Sport.hockey,
	"tennis": Sport.tennis,
	"volleyball": Sport.volleyball,
	"soccer": Sport.soccer,
};

/// Converts [Sport] values to Strings. 
/// 
/// Use this to convert to JSON, since they can only use Strings.
final Map<Sport, String> sportToString = Map.fromEntries(
	stringToSport.entries.map(
		(MapEntry<String, Sport> entry) => MapEntry(entry.value, entry.key)
	)
);

/// The scores for a [SportsGame].
/// 
/// This class provides helper functions that will simplify higher-level logic. 
@immutable
class Scores {
	/// The score for Ramaz. 
  final int ramazScore;

  /// The score for the other team.
  final int otherScore;

  /// Whether the game is being played at home. 
  /// 
  /// This dictates which score is returned for [getScore]. 
  final bool isHome;

  /// Holds the scores for a [SportsGame].
  const Scores(this.ramazScore, this.otherScore, {@required this.isHome});

  /// Creates a [Scores] object from a JSON entry. 
  /// 
  /// The entry must have: 
  /// 
	/// - an "isHome" field, which should be a bool. See [isHome].
	/// - an "otherScore" field, which should be an integer. See [otherScore].
	/// - a "ramazScore" field, which should be an integer. See [ramazScore]. 
  Scores.fromJson(Map<String, dynamic> json) : 
  	isHome = json ["isHome"],
  	ramazScore = json ["ramaz"],
  	otherScore = json ["other"];

	/// Converts this object to JSON. 
	/// 
	/// Passing the result of this function to [Scores.fromJson()] should
	/// return an equivalent object. 
  Map<String, dynamic> toJson() => {
  	"isHome": isHome,
  	"ramaz": ramazScore,
  	"other": otherScore,
  };
  
  @override
  String toString() => "Ramaz: $ramazScore, Other: $otherScore";

  /// If the game ended in a tie. 
  bool get didDraw => ramazScore == otherScore;

  /// If Ramaz won the game. 
  bool get didWin => ramazScore > otherScore;

  /// Gets the score for either the home team or the away team.
  int getScore({bool home}) => home == isHome 
	  ? ramazScore : otherScore;
}

/// A sports game. 
@immutable
class SportsGame {
	/// Converts a list of JSON entries into a list of [SportsGame]s. 
	/// 
	/// This method is needed since it casts each `dynamic` entry to a
	/// `Map<String, dynamic>`, and then passes those values to 
	/// [SportsGame.fromJson].
	static List<SportsGame> fromList(List<Map<String, dynamic>> listJson) => [
		for (final Map<String, dynamic> json in listJson) 
			SportsGame.fromJson(json)
	];

	/// The type of sport being played.
	final Sport sport;

	/// The date of the game. 
	/// 
	/// The time can be ignored since it is represented in [times].
	final DateTime date;

	/// The start and end times for this game. 
	/// 
	/// The date can be ignored since it is represented in [date].
	final Range times;

	/// The team playing the game. 
	// TODO(Levi): make sure this data is downloaded properly, #2
	final String team;

	/// The opponent school being played.
	final String opponent;

	/// Whether the game is being played at home or somewhere else. 
	/// 
	/// This affects the UI representation of the game, as well as [Scores.isHome].
	final bool home;

	/// The scores for this game. 
	/// 
	/// The [Scores] dataclass holds helper methods to simplify logic about who 
	/// won, and which score to get depending on [home].
	final Scores scores;

	/// Creates a game dataclass.
	const SportsGame({
		@required this.sport,
		@required this.date,
		@required this.times,
		@required this.team,
		@required this.opponent,
		@required this.home,
		this.scores,
	});

	/// Converts a JSON entry to a [SportsGame].
	/// 
	/// The JSON should have:
	/// 
	/// - a "sport" field (String)
	/// - a "date" field (String acceptable to [DateTime.parse]. Eg, "2012-02-27")
	/// - a "times" field. See [Range.fromJson] for format. 
	/// - a "teach" field (String)
	/// - a "home" field (bool)
	/// - an "opponent" field (String)
	/// - a "scores" field. See [Scores.fromJson] for format.
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

	/// Converts this game to JSON.
	/// 
	/// Passing the result of this function to [SportsGame.fromJson()] should
	/// return an equivalent object. 
	Map<String, dynamic> toJson() => {
		"sport": sportToString [sport],
		"date": "${date.year}-${date.month}-${date.day}",
		"times": times.toJson(),
		"team": team, 
		"home": home, 
		"opponent": opponent,
		"scores": scores.toJson(),
	};

	/// The name of the home team.
	String get homeTeam => home ? "Ramaz" : opponent;

	/// The name of the away team.
	String get awayTeam => home ? opponent : "Ramaz";

	/// Specifies which team is away and which team is home.
	String get description => "$awayTeam @ $homeTeam";
}
