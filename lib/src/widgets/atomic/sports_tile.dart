import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:url_launcher/url_launcher.dart";

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
  final int? score;
  
  /// Creates a row to represent some stats in a [SportsTile].
  const SportsStats({
    required this.team,
    required this.dateTime,
    this.score,
  });
  
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(flex: 1, child: Text(team)),
      Expanded(flex: 1, child: Text(score?.toString() ?? "")),
      Expanded(flex: 2, child: Center(child: Text(dateTime))),
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
  static Future<Scores?> updateScores(
  	BuildContext context,
  	SportsGame game
	) => showDialog<Scores>(
    context: context,
    builder: (_) => SportsScoreUpdater(game),
  );
  
  /// The game being edited. 
  /// 
  /// [SportsGame.isHome] is used to fill [Scores.isHome].
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
  int? ramazScore;

  /// The value of [otherController] as a number.
  int? otherScore;

  /// The [Scores] object represented by this widget. 
  Scores get scores => Scores(
    ramazScore: ramazScore!,  // only called if [ready] == true
    otherScore: otherScore!,  // only called if [ready] == true
    isHome: widget.game.isHome
  );

  /// Whether [scores] is valid and ready to submit.
  bool get ready => ramazController.text.isNotEmpty &&
    otherController.text.isNotEmpty &&
    ramazScore != null &&
    otherScore != null;
  
  @override
  void initState() {
    super.initState();
    ramazController.text = widget.game.scores?.ramazScore.toString() ?? "";
    otherController.text = widget.game.scores?.otherScore.toString() ?? "";
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
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Cancel"),
      ),
      ElevatedButton(
        onPressed: !ready ? null : () => Navigator.of(context).pop(scores),
        child: const Text("Save"),
      )
    ]
  );
}

/// A widget to represent a [SportsGame].
/// 
/// If [onTap] is not null, tapping on the card will allow the user to 
/// input new scores. To keep layers modular, and to be more flexible, 
/// the logic for what to do with [game], as well as determining if the user 
/// has the right permissions, is kept separate from this widget. 
/// 
/// Instead, a pass [onTap] to [SportsTile()].  
class SportsTile extends StatelessWidget {
  /// Formats [date] into month-day-year form.
  static String formatDate(DateTime? date) => 
    "${date?.month ?? ' '}-${date?.day ?? ' '}-${date?.year ?? ' '}";

  /// The game for this widget to represent. 
  final SportsGame game;

  /// What to do when the user taps this tile. 
  /// 
  /// Only administrators should be allowed to do anything, so this function
  /// should be null if the user is not an admin. However, what to do with
  /// [game] depends on the context, so is left to the parent widget. 
  /// 
  /// If this is non-null, an edit icon will be shown on this widget. 
  final VoidCallback? onTap;

  /// Creates a widget to display a [SportsGame].
  const SportsTile(this.game, {this.onTap});

  /// Retrieves the icon for `game.sport`.
  /// 
  /// This is deliberately kept as a switch-case (with no default) and not a 
  /// `Map<Sport, ImageProvider>` so that static analysis will report any missed
  /// cases. This use case is especially important (as opposed to parts of the 
  /// data library which are Maps) because any error here will show up on the 
  /// screen, instead of simply sending a bug report.
	IconData get icon {
		switch (game.sport) {
			case Sport.baseball: return Icons.sports_baseball;
			case Sport.basketball: return Icons.sports_basketball;
			case Sport.soccer: return Icons.sports_soccer;
			case Sport.hockey: return Icons.sports_hockey;
			case Sport.tennis: return Icons.sports_tennis;
			case Sport.volleyball: return Icons.sports_volleyball;
		}
	}
  
  /// The color of this widget. 
  /// 
  /// If Ramaz won, it's green.
  /// If Ramaz lost, it's red.
  /// If the game was tied, it's a light gray. 
  /// 
  /// This is a great example of why the helper class [Scores] exists.
  Color? get cardColor => game.scores == null ? null : 
    game.scores!.didDraw
			? const Color(0x4502b4fc)
			: (game.scores!.didWin ? const Color(0xad00ff48) : const Color(0xd8d32f2f));

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 160),
    child: Card(
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  icon, 
                  size: 36,
                  color: Theme.of(context).colorScheme.onBackground
                ),
                title: Text(game.team,textScaleFactor: 1.3),
                subtitle: Text(game.isHome
                	? "${game.opponent} @ Ramaz"
                	: "Ramaz @ ${game.opponent}",
                  textScaleFactor: 1.2,
              	),
                trailing: onTap == null ? ((game.livestreamUrl != null) ?
                IconButton(
                 icon: const Icon(Icons.live_tv),
                 onPressed: () {
                   if(game.livestreamUrl != null){
                    launch(game.livestreamUrl!);
                   }},
                  tooltip: "Watch livestream",
                ) : null) : const Icon(Icons.edit),
              ),
              const SizedBox(height: 20),
              SportsStats(
                team: game.awayTeam,
                score: game.scores?.getScore(home: false),
                dateTime: MaterialLocalizations.of(context)
                  .formatShortDate(game.date),
              ),
              const SizedBox(height: 10),
              SportsStats(
                team: game.homeTeam,
                score: game.scores?.getScore(home: true),
                dateTime: formatTimeRange(game.times,context),
              ),
            ]
          )
        ),
      )
    )
  );

  /// Formats a [Range] according to the user's locale.
  String formatTimeRange(Range times,BuildContext context) {
    final locale = MaterialLocalizations.of(context);
    final TimeOfDay start = TimeOfDay(
      hour: times.start.hour, 
      minute: times.start.minutes
    );
    final TimeOfDay end = TimeOfDay(
      hour: times.end.hour, 
      minute: times.end.minutes
    );
    return "${locale.formatTimeOfDay(start)} - ${locale.formatTimeOfDay(end)}";
  }
}
