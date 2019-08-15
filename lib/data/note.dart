import "package:flutter/foundation.dart" show required;
import "dart:convert" show JsonUnsupportedObjectError;

import "package:ramaz/data/schedule.dart";

// TODO: move repeat swtich case to its own function. 

enum RepeatableType {period, periodAndDay, subject}

const Map<RepeatableType, String> repeatableTypesToString = {
	RepeatableType.period: "period",
	RepeatableType.periodAndDay: "periodAndDay",
	RepeatableType.subject: "subject",
};

const Map<String, RepeatableType> stringToRepeatableTypes = {
	"period": RepeatableType.period,
	"periodAndDay": RepeatableType.periodAndDay,
	"subject": RepeatableType.subject,
};

class Note {
	final String message;
	final Repeatable repeat;
	final String type;

	const Note({
		@required this.message,
		this.type,
		this.repeat,
	});

	factory Note.fromJson(Map<String, dynamic> json) {
		Repeatable repeatable;
		if (json ["repeat"] != null) {
			final Map<String, dynamic> repeat = 
				Map<String, dynamic>.from(json ["repeat"]);
			final RepeatableType type = stringToRepeatableTypes [repeat ["type"]];
			try {
				switch (type) {
					case RepeatableType.period: 
						repeatable = RepeatablePeriod(
							period: repeat ["period"],
							letter: stringToLetters [repeat["letter"]],
						); 
						break;
					case RepeatableType.periodAndDay: 
						repeatable = RepeatablePeriodAndDay(
							period: repeat ["period"],
							letter: stringToLetters [repeat["letter"]],
						); 
						break;
					case RepeatableType.subject: 
						repeatable = RepeatableSubject(id: repeat ["id"]); 
						break;
					default: throw JsonUnsupportedObjectError(
						json,
						cause: "Invalid repeat type in note: $json",
					);
				}
			} on AssertionError catch (error) {
				throw JsonUnsupportedObjectError(
					json, 
					cause: (
						"Invalid repeat value in note: $json\m"
						"The specific error was: ${error.message}"
					)
				);
			}
		}
		return Note (
			message: json ["message"],
			repeat: repeatable,
			type: json ["repeat"] == null ? null : json ["repeat"] ["type"],
		);
	}

	static List<Note> fromList(List notes) => 
		notes.map((dynamic json) => Note.fromJson(Map<String, dynamic>.from(json))).toList();

	@override String toString() => "$message ($type)";

	Map<String, dynamic> toJson() => {
		"message": message,
		"repeat": repeat?.toJson(),
		"type": type,
	};

	bool get repeats => repeat == null;
}

abstract class Repeatable {
	bool doesApply({
		@required Letters letter, 
		@required PeriodData periodData, 
		@required String period,
	});
	const Repeatable();

	Map<String, dynamic> toJson();
}

class RepeatablePeriod extends Repeatable {
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
			"Invalid letter"
		),
		letter = stringToLetters [json["letter"]],
		period = json["period"] as String;

	@override 
	Map<String, dynamic> toJson() => {
		"letter": lettersToString [letter],
		"period": period,
		"type": "period",
	};

	@override
	bool doesApply({
		@required Letters letter, 
		@required PeriodData periodData, 
		@required String period,
	}) => letter == this.letter && period == this.period;
}

class RepeatablePeriodAndDay extends RepeatablePeriod {
	@override final Letters letter;
	@override final String period;

	const RepeatablePeriodAndDay({
		@required this.letter,
		@required this.period,
	}) : super (
		letter: letter,
		period: period
	);

	@override Map<String, dynamic> toJson() {
		final Map<String, dynamic> result = super.toJson();
		result ["type"] = "periodAndDay";
		return result;
	}
}

class RepeatableSubject extends Repeatable {
	final String id;

	const RepeatableSubject({
		@required this.id,
	}) : assert (id != null, "Id must not be null for note");

	@override 
	bool doesApply({
		@required Letters letter, 
		@required PeriodData periodData, 
		@required String period,
	}) => periodData.id == this.id;

	@override 
	Map<String, dynamic> toJson() => {
		"id": id,
		"type": "subject",
	};
}
