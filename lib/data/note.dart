import "package:flutter/foundation.dart" show required;
import "dart:convert" show JsonUnsupportedObjectError;

import "package:ramaz/data/schedule.dart";

enum RepeatableType {period, subject}

const Map<RepeatableType, String> repeatableTypesToString = {
	RepeatableType.period: "period",
	RepeatableType.subject: "subject",
};

const Map<String, RepeatableType> stringToRepeatableTypes = {
	"period": RepeatableType.period,
	"subject": RepeatableType.subject,
};

class Note {
	final String message;
	final Repeatable repeat;

	const Note({
		@required this.message,
		this.repeat,
	});

	factory Note.fromJson(Map<String, dynamic> json) => Note (
		message: json ["message"],
		repeat: json ["repeat"] == null ? null 
		: Repeatable.fromJson(
			stringToRepeatableTypes [json ["repeat"] ["type"]],
			Map<String, dynamic>.from(json ["repeat"]),
		),
	);

	static List<Note> fromList(List notes) => notes.map(
		(dynamic json) => Note.fromJson(Map<String, dynamic>.from(json))).toList();

	@override String toString() => "$message ($repeat)";

	Map<String, dynamic> toJson() => {
		"message": message,
		"repeat": repeat?.toJson(),
	};

	bool get repeats => repeat == null;
}

abstract class Repeatable {
	final RepeatableType type = null;
	const Repeatable();

	factory Repeatable.fromJson(RepeatableType type, Map<String, dynamic> json) {
		switch (type) {
			case RepeatableType.period: return RepeatablePeriod.fromJson(json);
			case RepeatableType.subject: return RepeatableSubject.fromJson(json);
			default: throw JsonUnsupportedObjectError(
				json,
				cause: "Invalid repeat type in note: $json",
			);
		}
	}

	factory Repeatable.fromType({
		@required RepeatableType type,
		@required Letters letter,
		@required String period,
		@required String course,
	}) {
		switch (type) {
			case RepeatableType.period: return RepeatablePeriod(
				period: period,
				letter: letter,
			); case RepeatableType.subject: return RepeatableSubject(
				name: course
			); default: throw ArgumentError.notNull("type");
		}
	}

	Map<String, dynamic> toJson();

	bool doesApply({
		@required Letters letter, 
		@required Subject subject, 
		@required String period,
	});


}

class RepeatablePeriod extends Repeatable {
	final RepeatableType type = RepeatableType.period;

	final Letters letter;
	final String period;

	const RepeatablePeriod({
		@required this.letter,
		@required this.period,
	}) : 
		assert(letter != null, "Letter must not be null for note"),
		assert(period != null, "Period must not be null for note");

	@override 
	RepeatablePeriod.fromJson(Map<String, dynamic> json) :
		assert (
			stringToLetters.containsKey(json ["letters"]), 
			"Invalid letter for note: $json"
		),
		letter = stringToLetters [json["letter"]],
		period = json["period"] as String;

	@override 
	Map<String, dynamic> toJson() => {
		"letter": lettersToString [letter],
		"period": period,
		"type": repeatableTypesToString [type],
	};

	@override
	bool doesApply({
		@required Letters letter, 
		@required Subject subject, 
		@required String period,
	}) => letter == this.letter && period == this.period;

	@override String toString() => 
		"Repeats every ${lettersToString[letter]}-$period";
}

class RepeatableSubject extends Repeatable {
	final RepeatableType type = RepeatableType.subject;

	final String name;

	const RepeatableSubject({
		@required this.name,
	}) : assert (name != null, "Name must not be null for note repeat");

	@override 
	factory RepeatableSubject.fromJson(Map<String, dynamic> json) => 
		RepeatableSubject(name: json ["name"]);

	@override 
	Map<String, dynamic> toJson() => {
		"name": name,
		"type": "subject",
	};

	@override 
	bool doesApply({
		@required Letters letter, 
		@required Subject subject, 
		@required String period,
	}) => subject.name == this.name;

	@override String toString() => "Repeats every $name";
}
