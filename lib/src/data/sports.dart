import "package:meta/meta.dart";

import "package:ramaz/constants.dart" show DayComparison;

import "schedule/time.dart";

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
  const Scores({
  	required this.ramazScore, 
  	required this.otherScore,
  	required this.isHome
	});

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
  int getScore({required bool home}) => home == isHome 
	  ? ramazScore : otherScore;
}

/// A sports game. 
@immutable
class SportsGame {
	/// Capitalizes a word. 
	/// 
	/// Useful for the [Sport] enum. 
	static String capitalize(Sport sport) => 
		sportToString [sport]! [0].toUpperCase() 
		+ sportToString [sport]!.substring(1);

	/// Converts a list of JSON entries into a list of [SportsGame]s. 
	/// 
	/// This method is needed since it casts each `dynamic` entry to a
	/// `Map<String, dynamic>`, and then passes those values to 
	/// [SportsGame.fromJson].
	static List<SportsGame> fromList(List<Map<String, dynamic>> listJson) => [
		for (final Map<String, dynamic> json in listJson) 
			SportsGame.fromJson(json)
	];

	/// Converts a list of [SportsGame]s into a list of JSON entries. 
	static List<Map<String, dynamic>> getJsonList(List<SportsGame> games) => [
		for (final SportsGame game in games) 
			game.toJson()
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
	final bool isHome;

	/// The scores for this game. 
	/// 
	/// The [Scores] dataclass holds helper methods to simplify logic about who 
	/// won, and which score to get depending on [isHome].
	final Scores? scores;

	/// Creates a game dataclass.
	const SportsGame({
		required this.sport,
		required this.date,
		required this.times,
		required this.team,
		required this.opponent,
		required this.isHome,
		this.scores,
	});

	/// Converts a JSON entry to a [SportsGame].
	/// 
	/// The JSON should have:
	/// 
	/// - a "sport" field (String)
	/// - a "date" field (String acceptable to [DateTime.parse]. Eg, "2012-02-27")
	/// - a "times" field. See [Range.fromJson] for format. 
	/// - a "team" field (String)
	/// - a "home" field (bool)
	/// - an "opponent" field (String)
	/// - a "scores" field. See [Scores.fromJson] for format.
	SportsGame.fromJson(Map<String, dynamic> json) :
		sport = stringToSport [json ["sport"]]!,
		date = DateTime.parse(json ["date"]),
		times = Range.fromJson(json ["times"]),
		team = json ["team"],
		isHome = json ["isHome"],
		opponent = json ["opponent"],
		scores = json ["scores"] == null ? null : Scores.fromJson(
			Map<String, dynamic>.from(json ["scores"])
		);

	// Specifically not including scores, since this can be used 
	// to replace scores. 
	@override
	bool operator == (dynamic other) => other is SportsGame && 
		other.sport == sport && 
		other.opponent == opponent && 
		other.isHome == isHome && 
		other.team == team && 
		other.date.isSameDay(date) && 
		other.times == times;

	@override 
	int get hashCode => "$isHome-$opponent-$sport-$team-$date-$times".hashCode;

	/// Converts this game to JSON.
	/// 
	/// Passing the result of this function to [SportsGame.fromJson()] should
	/// return an equivalent object. 
	Map<String, dynamic> toJson() => {
		"sport": sportToString [sport],
		"date": date.toString(),
		"times": times.toJson(),
		"team": team, 
		"isHome": isHome, 
		"opponent": opponent,
		"scores": scores?.toJson(),
	};

	/// The end of the match. 
	/// 
	/// This is convenient for checking if the game already passed. 
	DateTime get dateTime => DateTime(
		date.year, 
		date.month, 
		date.day,
		times.end.hour, 
		times.end.minutes,
	);

	/// Returns a new [SportsGame] with the scores switched out. 
	/// 
	/// This method allows [SportsGame]s to stay immutable. 
	SportsGame replaceScores(Scores newScores) => SportsGame(
		sport: sport,
		team: team,
		isHome: isHome,
		date: date, 
		opponent: opponent,
		times: times, 
		scores: newScores,
	);

	/// The name of the home team.
	String get homeTeam => isHome ? "Ramaz" : opponent;

	/// The name of the away team.
	String get awayTeam => isHome ? opponent : "Ramaz";

	/// Specifies which team is away and which team is home.
	String get description => "$awayTeam @ $homeTeam";
}
