import "package:flutter/foundation.dart" show required;

import "package:ramaz/data/schedule.dart" show Letters, lettersToString;

class Note {
	final String message, period;
	final DateTime date;
	final Letters letter;

	const Note({
		@required this.message,
		@required this.period,
		@required this.letter,
		this.date,
	});

	static Note fromJson(Map<String, dynamic> json) => Note (
		message: json ["message"],
		period: json ["period"],
		letter: json ["letter"],
		date: json ["date"],
	);

	static List<Note> fromList(List<Map<String, dynamic>> notes) => 
		notes.map(Note.fromJson).toList();

	Map<String, dynamic> toJson() => {
		"message": message,
		"period": period,
		"letter": lettersToString [letter],
		"date": date,
	};

	bool get repeats => date == null;
}
