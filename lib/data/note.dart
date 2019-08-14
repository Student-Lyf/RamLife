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

	static Note fromJson(Map<dynamic, dynamic> json) {
		return Note (
			message: json ["message"],
			period: json ["period"],
			letter: json ["letter"],
			date: json ["data"] == null ? null : DateTime.parse(json ["date"].toDate()),
		);
	}

	static List<Note> fromList(List notes) => 
		notes.map((dynamic json) => Note.fromJson(json as Map)).toList();

	Map<String, dynamic> toJson() => {
		"message": message,
		"period": period,
		"letter": lettersToString [letter],
		"date": date?.toString(),
	};

	@override String toString() => message;

	bool get repeats => date == null;
}
