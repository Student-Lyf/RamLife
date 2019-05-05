import "package:flutter/foundation.dart";

enum Sports {Baseball, Basketball, Hockey, Tennis, Volleyball, Soccer}

class SportsGame {
	final Sports sport;
	final bool home;
	final String opponent, timestamp, info;
	final DateTime start, end;
	SportsGame({
		@required this.sport,
		@required this.home,
		@required this.opponent,
		@required this.start,
		@required this.end		
	}) : 
		timestamp = "${start.hour}:${start.minute}-${end.hour}:${end.minute}",
		info = home
			? "$opponent @ Ramaz"
			: "Ramaz @ $opponent";
}