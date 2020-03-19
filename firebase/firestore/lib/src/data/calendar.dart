import "package:meta/meta.dart";

import "package:firestore/helpers.dart";

import "letters.dart";

/// A day in the schedule.
@immutable
class Day extends Serializable {
	/// The date for this day.
	final DateTime date;

	/// The letter for this day.
	final Letter letter;

	/// The special schedule for this day.
	/// 
	/// If null, the app will decide what schedule to use based on its defaults.
	final String special;

	/// Creates a day in the schedule.
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