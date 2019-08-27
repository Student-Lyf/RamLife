import "package:ramaz/data.dart";

final List<SportsGame> games = [
	SportsGame (  // future
		sport: Sports.basketball,
		opponent: "SAR",
		home: false,
		time: SchoolEvent (
			start: DateTime(2020, 5, 5, 5, 0),
			end: DateTime(2020, 5, 5, 7, 0),
		)
	),
	SportsGame (
		sport: Sports.tennis,
		opponent: "Frisch",
		home: true,
		time: SchoolEvent (
			start: DateTime(2019, 8, 26, 12, 0),
			end: DateTime(2019, 8, 26, 3, 30),
		)
	)
];
