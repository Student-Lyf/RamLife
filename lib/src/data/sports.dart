// TODO: girls/boys
// TODO: get score/finished

import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";

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
			"${time.start.hour}:"
			"${time.start.minute}-"
			"${time.end.hour}:"
			"${time.end.minute}",
		info = home
			? "$opponent @ Ramaz"
			: "Ramaz @ $opponent";
}
