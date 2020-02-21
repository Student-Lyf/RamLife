import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/widgets.dart";

class SportsStats extends StatelessWidget {
  final String team, dateTime;
  final int score;  
  
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

class SportsScoreUpdater extends StatefulWidget {
  static Future<Scores> updateGame(
  	BuildContext context, 
  	SportsGame game
	) => showDialog<Scores>(
    context: context,
    builder: (_) => SportsScoreUpdater(game),
  );
  
  final SportsGame game;
  const SportsScoreUpdater(this.game);
  
  @override
  ScoreUpdaterState createState() => ScoreUpdaterState();
}

class ScoreUpdaterState extends State<SportsScoreUpdater> {
  TextEditingController ramazController, otherController;
  
  Scores get scores => Scores(
  	int.parse(ramazController.text), 
  	int.parse(otherController.text),
  	isHome: widget.game.home,
	);

  bool get ready => ramazController.text.isNotEmpty && 
	  otherController.text.isNotEmpty;
  
  @override
  void initState() {
    super.initState();
    ramazController = TextEditingController();
    otherController = TextEditingController();
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
                onChanged: (_) => setState(() {}),
              )
            ),
            const SizedBox(width: 50),
            SizedBox(
              width: 20, 
              child: TextField(
                controller: otherController,
                onChanged: (_) => setState(() {}),
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

class SportsTile extends StatelessWidget {
  final SportsGame game;
  final void Function(Scores) updateScores;
  const SportsTile(this.game, [this.updateScores]);

	Icon get icon {
		switch (game.sport) {
			case Sport.baseball: return SportsIcons.baseball;
			case Sport.basketball: return SportsIcons.basketball;
			case Sport.soccer: return SportsIcons.soccer;
			case Sport.hockey: return SportsIcons.hockey;
			case Sport.tennis: return SportsIcons.tennis;
			case Sport.volleyball: return SportsIcons.volleyball;
		}
		return null;  // no default to keep static analysis
	}
  
  Color get cardColor => game.scores != null
	  ? (game.scores.didDraw
			? Colors.blueGrey 
			: (game.scores.didWin ? Colors.lightGreen : Colors.red [400])
		) : null;
   
  String formatDate(DateTime date) => 
    "${date.month}-${date.day}-${date.year}";

  int get padLength => game.opponent.length > "Ramaz".length
    ? game.opponent.length : "Ramaz".length;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 160,
    child: Card(
      color: cardColor,
      child: InkWell(
      	onTap: updateScores == null ? null : () async => updateScores(
      	  await SportsScoreUpdater.updateGame(context, game)
      	),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              ListTile(
                leading: icon,
                title: Text(game?.team ?? ""),
                subtitle: Text(game.home 
                	? "${game.opponent} @ Ramaz" 
                	: "Ramaz @ ${game.opponent}"
              	),
              ),
              const SizedBox(height: 20),
              SportsStats(
                team: game.awayTeam.padRight(padLength),
                score: game.scores.getScore(home: false),
                dateTime: formatDate(game.date),
              ),
              const SizedBox(height: 10),
              SportsStats(
                team: game.homeTeam.padRight(padLength),
                score: game.scores.getScore(home: true),
                dateTime: game.times.toString(),
              ),
            ]
          )
        ),
      )
    )
  );
}
