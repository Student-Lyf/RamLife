import "package:meta/meta.dart";

import "package:firestore/serializable.dart";

enum Letter {M, R, A, B, C, E, F}

@immutable
class Day extends Serializable {
	final DateTime date;
	final Letter letter;
	final String special;

	const Day({
		@required this.date, 
		@required this.letter, 
		this.special
	});

	@override
	String toString() => letter != null 
		? "$date: $letter ${special ?? ''}"
		: "$date: No School";

	@override
	Map<String, dynamic> get json => {
		"letter": letter,
		"special": special,
	};
}