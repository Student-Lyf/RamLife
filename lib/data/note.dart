import "package:flutter/foundation.dart" show required;
import "dart:convert" show JsonUnsupportedObjectError;

import "package:ramaz/data/schedule.dart";

enum NoteTimeType {period, subject}

const Map<NoteTimeType, String> noteTimeToString = {
	NoteTimeType.period: "period",
	NoteTimeType.subject: "subject",
};

const Map<String, NoteTimeType> stringToNoteTime = {
	"period": NoteTimeType.period,
	"subject": NoteTimeType.subject,
};

abstract class NoteTime {
	final NoteTimeType type = null;
	final bool repeats;
	const NoteTime(this.repeats);

	factory NoteTime.fromJson(Map<String, dynamic> json) {
		switch (stringToNoteTime [json ["type"]]) {
			case NoteTimeType.period: return PeriodNoteTime.fromJson(json);
			case NoteTimeType.subject: return SubjectNoteTime.fromJson(json);
			default: throw JsonUnsupportedObjectError(
				json,
				cause: "Invalid time for note: $json"
			);
		}
	}

	factory NoteTime.fromType({  // for use in the UI
		@required NoteTimeType type,
		@required Letters letter,
		@required String period,
		@required String name,
		@required bool repeats,
	}) {
		switch (type) {
			case NoteTimeType.period: return PeriodNoteTime(
				period: period,
				letter: letter,
				repeats: repeats,
			); case NoteTimeType.subject: return SubjectNoteTime(
				name: name,
				repeats: repeats,
			); default: throw ArgumentError.notNull("type");
		}
	}

	Map<String, dynamic> toJson();

	bool doesApply({
		@required Letters letter, 
		@required String subject, 
		@required String period,
	});

	String toString();  // no way to enforce :(
}

class PeriodNoteTime extends NoteTime {
	@override
	final NoteTimeType type = NoteTimeType.period;

	final Letters letter;
	final String period;

	const PeriodNoteTime({
		@required this.letter,
		@required this.period,
		@required bool repeats
	}) : super (repeats);

	PeriodNoteTime.fromJson(Map<String, dynamic> json) :
		letter = stringToLetters [json ["letter"]],
		period = json ["period"],
		super (json ["repeats"]);

	@override
	String toString() => 
		(repeats ? "Repeats every " : "") + 
		"${lettersToString [letter]}-$period";

	@override 
	Map<String, dynamic> toJson() => {
		"letter": lettersToString [letter],
		"period": period,
		"repeats": repeats,
		"type": noteTimeToString [type],
	};

	@override
	bool doesApply({
		@required Letters letter, 
		@required String subject, 
		@required String period,
	}) => letter == this.letter && period == this.period;
}

class SubjectNoteTime extends NoteTime {
	@override 
	final NoteTimeType type = NoteTimeType.subject;

	final String name;

	const SubjectNoteTime({
		@required this.name,
		@required bool repeats,
	}) : super (repeats);

	SubjectNoteTime.fromJson(Map<String, dynamic> json) :
		name = json ["name"],
		super (json ["repeats"]);

	@override
	String toString() => (repeats ? "Repeats every " : "") + name;

	@override 
	Map<String, dynamic> toJson() => {
		"name": name,
		"repeats": repeats,
		"type": noteTimeToString [type],
	};

	@override
	bool doesApply({
		@required Letters letter, 
		@required String subject, 
		@required String period,
	}) => subject == name;
}

// used for iterating over notes
Iterable<int> range(int stop) sync* {
	for (int index = 0; index < stop; index++) {
		yield index;
	}
}

class Note {
	static Iterable<int> getNotes({
		@required List<Note> notes,
		@required Letters letter,
		@required String period,
		@required String subject,
	}) => range(notes.length).where(
		(int index) => notes [index].time.doesApply(
			letter: letter,
			period: period,
			subject: subject
		)
	);

	static List<Note> fromList(List notes) => notes.map(
		(dynamic json) => Note.fromJson(Map<String, dynamic>.from(json))).toList();

	final String message;
	final NoteTime time;

	bool shown;

	Note({
		@required this.message,
		this.time,
		this.shown = false,
	});

	factory Note.fromJson(Map<String, dynamic> json) => Note (
		message: json ["message"],
		time: NoteTime.fromJson(json ["time"]),
		shown: json ["shown"],
	);

	@override String toString() => "$message ($time)";

	Map<String, dynamic> toJson() => {
		"message": message,
		"time": time.toJson(),
		"shown": shown,
	};
}
