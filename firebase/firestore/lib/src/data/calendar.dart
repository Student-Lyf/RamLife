import "package:meta/meta.dart";

import "package:firestore/helpers.dart";

import "letters.dart";

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