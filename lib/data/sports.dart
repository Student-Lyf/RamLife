import "package:flutter/foundation.dart";

import "package:ramaz/data/times.dart";

enum Sports {baseball, basketball, hockey, tennis, volleyball, soccer}

class SportsGame {
	final Sports sport;
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
			"${time.time.start.hour}:"
			"${time.time.start.minutes}-"
			"${time.time.end.hour}:"
			"${time.time.end.minutes}",
		info = home
			? "$opponent @ Ramaz"
			: "Ramaz @ $opponent";
}