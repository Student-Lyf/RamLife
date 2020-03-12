import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/widgets.dart";

/// A row in a [SportsTile] that displays a team, their score, 
/// and a part of the date.
class SportsStats extends StatelessWidget {
  /// The team being represented.
  final String team;

  /// The date or time. 
  /// 
  /// There are two [SportsStats] in a [SportsTile]. The top one shows the date,
  /// and the bottom one shows the time.
  /// 
  /// This type is a String so it can represent both.
  final String dateTime;

  /// The score for [team].
  final int score;
  
  /// Creates a row to represent some stats in a [SportsTile].
  const SportsStats({
    @required this.team,
    @required this.dateTime,
    @required this.score,
  });
  
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(team),
      const Spacer(flex: 2),
      Text(score?.toString() ?? ""),
      const Spacer(flex: 3),
      Text(dateTime),
      const Spacer(),
    ]
  );
}

/// A dialog to update the scores for a [SportsGame].
/// 
/// Use [SportsScoreUpdater.updateScores] to display this widget. 
class SportsScoreUpdater extends StatefulWidget {
  /// Opens a dialog to prompt the user for the scores of the game. 
  /// 
  /// Returns the scores as inputted.
  static Future<Scores> updateScores(
  	BuildContext context,
  	SportsGame game
	) => showDialog<Scores>(
    context: context,
    builder: (_) => SportsScoreUpdater(game),
  );
  
  /// The game being edited. 
  /// 
  /// [SportsGame.home] is used to fill [Scores.isHome].
  final SportsGame game;

  /// Creates a widget to get the scores for [game] from the user.
  const SportsScoreUpdater(this.game);
  
  @override
  ScoreUpdaterState createState() => ScoreUpdaterState();
}

/// The state for [SportsScoreUpdater]. 
/// 
/// Needed to keep the state of the [TextEditingController]s. 
class ScoreUpdaterState extends State<SportsScoreUpdater> {
  /// The controller for the Ramaz score [TextField]/
  final TextEditingController ramazController = TextEditingController(); 

  /// The controller for the opponent's score [TextField]/
  final TextEditingController otherController = TextEditingController();

  /// The value of [ramazController] as a number.
  int ramazScore;

  /// The value of [otherController] as a number.
  int otherScore;

  /// The [Scores] object represented by this widget. 
  Scores get scores => Scores(ramazScore, otherScore, isHome: widget.game.home);

  /// Whether [scores] is valid and ready to submit.
  bool get ready => ramazController.text.isNotEmpty &&
    otherController.text.isNotEmpty &&
    ramazScore != null &&
    otherScore != null;
  
  @override
  void initState() {
    super.initState();
    ramazController.text = widget.game.scores?.ramazScore?.toString();
    otherController.text = widget.game.scores?.otherScore?.toString();
    ramazScore = int.tryParse(ramazController.text);
    otherScore = int.tryParse(otherController.text);
  }
  
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text("Update Scores"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Ramaz"),
            const SizedBox(width: 50),
            Text(widget.game.opponent),
          ]
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              child: TextField(
                controller: ramazController,
                onChanged: (String score) => setState(
                  () => ramazScore = int.tryParse(score)
                ),
                keyboardType: TextInputType.number,
              )
            ),
            const SizedBox(width: 50),
            SizedBox(
              width: 20,
              child: TextField(
                controller: otherController,
                onChanged: (String score) => setState(
                  () => otherScore = int.tryParse(score)
                ),
                keyboardType: TextInputType.number,
              )
            ),
          ]
        )
      ]
    ),
    actions: [
      FlatButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Cancel"),
      ),
      RaisedButton(
        onPressed: !ready ? null : () => Navigator.of(context).pop(scores),
        child: const Text("Save"),
      )
    ]
  );
}

/// A widget to represent a [SportsGame].
/// 
/// If [updateScores] is not null, tapping on the card will allow the user to 
/// input new scores. To keep layers modular, and to be more flexible, 
/// the logic for actually updating the scores in the data source, as well as 
/// determining if the user has permission to update the scores, is kept 
/// separate from this widget. Instead, a function taking the new scores is to 
/// be passed as [SportsTile()] and will be used with the new scores from 
/// calling [SportsScoreUpdater.updateScores].  
class SportsTile extends StatelessWidget {
  // TODO: Decide on widget or letter.
  /// The game for this widget to represent. 
  final SportsGame game;

  /// What to do with the scores when they are updated. 
  /// 
  /// If this function is null, tapping on this widget will not show a 
  /// [SportsScoreUpdater].
  final void Function(Scores) updateScores;

  /// Creates a widget to display a [SportsGame].
  const SportsTile(this.game, {this.updateScores});

  /// Retrieves the icon for `game.sport`.
  /// 
  /// This is deliberately kept as a switch-case (with no default) and not a 
  /// `Map<Sport, ImageProvider>` so that static analysis will report any missed
  /// cases. This use case is especially important (as opposed to parts of the 
  /// data library which are Maps) because any error here will show up on the 
  /// screen, instead of simply sending a bug report.
	ImageProvider get icon {
		switch (game.sport) {
			case Sport.baseball: return SportsIcons.baseball;
			case Sport.basketball: return SportsIcons.basketball;
			case Sport.soccer: return SportsIcons.soccer;
			case Sport.hockey: return SportsIcons.hockey;
			case Sport.tennis: return SportsIcons.tennis;
			case Sport.volleyball: return SportsIcons.volleyball;
		}
		return null;
	}

  // String get sportLetter {
  //   switch(game.sport) {
  //     case Sport.baseball: return "B";
  //     case Sport.basketball: return "B";
  //     case Sport.volleyball: return "V";
  //     case Sport.tennis: return "T";
  //     case Sport.hockey: return "H";
  //     case Sport.soccer: return "S";
  //     default: return "X";
  //   }
  // }
  
  /// The color of this widget. 
  /// 
  /// If Ramaz won, it's green.
  /// If Ramaz lost, it's red.
  /// If the game was tied, it's a light grey. 
  /// 
  /// This is a great example of why the helper class [Scores] exists.
  Color get cardColor => game.scores != null
	  ? (game.scores.didDraw
			? Colors.blueGrey
			: (game.scores.didWin ? Colors.lightGreen : Colors.red [400])
		) : null;
   
  /// Formats [date] into month-day-year form.
  String formatDate(DateTime date) => 
    "${date?.month ?? ' '}-${date?.day ?? ' '}-${date?.year ?? ' '}";


  /// Determines how long to pad the team names so they align.
  int get padLength => game.opponent.length > "Ramaz".length
    ? game.opponent.length : "Ramaz".length;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 160,
    child: Card(
      color: cardColor,
      child: InkWell(
      	onTap: updateScores == null ? null : () async => updateScores(
      	  await SportsScoreUpdater.updateScores(context, game)
      	),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar (
                  backgroundImage: icon,
                  backgroundColor: Theme.of(context).cardColor
                ),
                title: Text(game?.team ?? ""),
                subtitle: Text(game.home
                	? "${game.opponent} @ Ramaz"
                	: "Ramaz @ ${game.opponent}"
              	),
              ),
              const SizedBox(height: 20),
              SportsStats(
                team: game.awayTeam.padRight(padLength),
                score: game.scores?.getScore(home: false),
                dateTime: formatDate(game.date),
              ),
              const SizedBox(height: 10),
              SportsStats(
                team: game.homeTeam.padRight(padLength),
                score: game.scores?.getScore(home: true),
                dateTime: (game.times).toString(),
              ),
            ]
          )
        ),
      )
    )
  );
}
