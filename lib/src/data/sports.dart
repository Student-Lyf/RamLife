// TODO: girls/boys
// TODO: get score/finished

import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";

enum Sport {baseball, basketball, hockey, tennis, volleyball, soccer}

class SportsGame {
	final Sport sport;
	final bool home;
	final String opponent, timestamp, info;
	final SchoolEvent time;
	SportsGame({
		@required this.sport,
		@required this.home,
		@required this.opponent,
		@required this.time
	}) : 
		timestamp = 
			"${time.start.hour}:"
			"${time.start.minute.toString().padRight(2, "0")}-"
			"${time.end.hour}:"
			"${time.end.minute.toString().padRight(2, "0")}",
		info = home
			? "$opponent @ Ramaz"
			: "Ramaz @ $opponent";
}
