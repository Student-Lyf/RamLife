/// This library handles serialization and deserialization of notes. 
/// 
/// Each note a [Note.time] property, which is a [NoteTime], describing when 
/// said note should be displayed. Since notes could be shown on a specific
/// class or period, the classes [PeriodNoteTime] and [SubjectNoteTime] were made. 
library note_dataclasses;

import "package:flutter/foundation.dart";
import "dart:convert" show JsonUnsupportedObjectError;

import "schedule.dart";

/// An enum to decide when the note should appear. 
/// 
/// `period` means the note needs a [Letters] and a period (as [String])
/// `subject` means the note needs a name of a class.
enum NoteTimeType {
	/// Whether the note should be displayed on a specific period.
	period, 

	/// Whether the note should be displayed on a specific subject.
	subject
}

/// Used to convert [NoteTimeType] to JSON.
const Map<NoteTimeType, String> noteTimeToString = {
	NoteTimeType.period: "period",
	NoteTimeType.subject: "subject",
};

/// Used to convert JSON to [NoteTimeType].
const Map<String, NoteTimeType> stringToNoteTime = {
	"period": NoteTimeType.period,
	"subject": NoteTimeType.subject,
};

/// A time that a note should show.
/// 
/// Should be used for [Note.time].
@immutable
abstract class NoteTime {
	/// The type of note. 
	/// 
	/// This field is here for other objects to use. 
	final NoteTimeType type = null;

	/// Whether the note should repeat.
	final bool repeats;

	/// Allows its subclasses to be `const`. 
	const NoteTime(this.repeats);

	/// Initializes a new instace from JSON.
	/// 
	/// Mainly looks at `json ["type"]` to choose which type of 
	/// [NoteTime] it should instantiate, and then leaves the 
	/// work to that subclasses `.fromJson` method. 
	/// 
	/// Example JSON: 
	/// ```
	/// {
	/// 	"type": "period",
	/// 	"repeats": false,
	/// 	"period": "9",
	/// 	"letter": "M",
	/// }
	/// ```
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

	/// Instantiates new [NoteTime] with all possible parameters. 
	/// 
	/// Used for cases where the caller doesn't care about the [NoteTimeType],
	/// such as a UI notes builder. 
	factory NoteTime.fromType({
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

	/// Returns this [NoteTime] as JSON.
	Map<String, dynamic> toJson();

	/// Checks if the [Note] should be displayed.
	/// 
	/// All possible parameters are required. 
	bool doesApply({
		@required Letters letter, 
		@required String subject, 
		@required String period,
	});

	/// Returns a String representation of this [NoteTime].
	///
	/// Used for debugging and throughout the UI.
	String toString();
}

/// A [NoteTime] that depends on a [Letters] and period.
@immutable
class PeriodNoteTime extends NoteTime {
	@override
	final NoteTimeType type = NoteTimeType.period;

	/// The [Letters] for when this [Note] should be displayed.
	final Letters letter;

	/// The period when this [Note] should be displayed.
	final String period;

	/// Returns a new [PeriodNoteTime].
	/// 
	/// All paremeters must be non-null.
	const PeriodNoteTime({
		@required this.letter,
		@required this.period,
		@required bool repeats
	}) : super (repeats);

	/// Creates a new [NoteTime] from JSON.
	/// 
	/// `json ["letter"]` should be one of: 
	/// 
	/// * M
	/// * R
	/// * A
	/// * B
	/// * C
	/// * E
	/// * F
	/// 
	/// `json ["period"]` should be a valid period for that letter,
	/// regardless of any schedule changes (like an "early dismissal").
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

	/// Returns true if [letter] and [period] match the parameters.
	@override
	bool doesApply({
		@required Letters letter, 
		@required String subject, 
		@required String period,
	}) => letter == this.letter && period == this.period;
}

/// A [NoteTime] that depends on a subject. 
@immutable
class SubjectNoteTime extends NoteTime {
	@override 
	final NoteTimeType type = NoteTimeType.subject;

	/// The name of the subject this [NoteTime] depends on.
	final String name;

	/// Returns a new [SubjectNoteTime]. All parameters must be non-null.
	const SubjectNoteTime({
		@required this.name,
		@required bool repeats,
	}) : super (repeats);

	/// Returns a new [SubjectNoteTime] from a JSON object.
	/// 
	/// The fields `repeats` and `name` must not be null.
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

	/// Returns true if [subject] matches the `subject` parameter.
	@override
	bool doesApply({
		@required Letters letter, 
		@required String subject, 
		@required String period,
	}) => subject == name;
}

/// A Python-like `range` function.
/// 
/// Like Python's `range`, this function returns an iterator
/// that gives all values from 0 until `stop`, with 1 at a time. 
/// This is simply for iterating over lists while keeping the index.
Iterable<int> range(int stop) sync* {
	for (int index = 0; index < stop; index++) {
		yield index;
	}
}

/// A user-generated note.
@immutable
class Note {
	/// Returns all notes from a list of notes that should be shown. 
	/// 
	/// All possible parameters are required. 
	/// This function delegates logic to [NoteTime.doesApply]
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

	/// Returns a list of notes from a list of JSON objects. 
	/// 
	/// Calls [Note.fromJson] for every JSON object in the list.
	static List<Note> fromList(List notes) => notes.map(
		(dynamic json) => Note.fromJson(Map<String, dynamic>.from(json))).toList();

	/// The message this note should show. 
	final String message;

	/// The [NoteTime] for this note. 
	final NoteTime time;

	/// Returns a new note.
	const Note({
		@required this.message,
		this.time,
	});

	/// Returns a new [Note] from a JSON object.
	/// 
	/// Uses `json ["message"]` for the message and passes `json["time"]` to [NoteTime.fromJson]
	factory Note.fromJson(Map<String, dynamic> json) => Note (
		message: json ["message"],
		time: NoteTime.fromJson(json ["time"]),
	);

	@override String toString() => "$message ($time)";

	/// Returns a JSON representation of this note.
	Map<String, dynamic> toJson() => {
		"message": message,
		"time": time.toJson(),
	};
}
