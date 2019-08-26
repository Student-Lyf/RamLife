import "package:ramaz/data/sports.dart";
import "package:ramaz/data/times.dart";

final List<SportsGame> games = [
	SportsGame (  // future
		sport: Sports.basketball,
		opponent: "SAR",
		home: false,
		time: SchoolEvent (
			year: 2020,
			month: 5,
			day: 5,
			time: Range.nums(5, 00, 7, 00)
		)
	),
	SportsGame (
		sport: Sports.tennis,
		opponent: "Frisch",
		home: true,
		time: SchoolEvent (
			year: 2019, 
			month: 5,
			day: 5,
			time: Range.nums(12, 00, 3, 30)  // it's a Sunday :)
		)
	)
];