import "package:flutter/foundation.dart";

// TODO: move this import into Reader
import "dart:convert" show jsonDecode;

import "schedule.dart";
import "times.dart";

// helper function to resolve issue of storing days in the DB:
Letters stringToLetter (String letter) {
	switch (letter) {
		case "A": return Letters.A;
		case "B": return Letters.B;
		case "C": return Letters.C;
		case "M": return Letters.M;
		case "R": return Letters.R;
		case "E": return Letters.E;
		case "F": return Letters.F;
		default: throw ArgumentError.value (
			letter,  // invalid value
			"stringToLetter",  // Function name
			"Letter must be one of ${Letters.values}"
		);
	}
}
const LETTERS = ["A", "B", "C", "M", "R", "E", "F"];

class Student {
	final Map <Letters, Schedule> schedule;
	final Letters homeroomDay;
	final String homeroomMeeting;
	final Map <Letters, String> minchaRooms;
	final Map<int, Subject> subjects;

	const Student ({
		@required this.schedule,
		@required this.homeroomDay,
		@required this.homeroomMeeting,
		@required this.minchaRooms,
		@required this.subjects
	});

	factory Student.fromData (Map<String, dynamic> data) {
		// For some reason, dart:convert.encodeJson() doesn't deep encode
		// Meaning that some values are still in JSON form
		// Here, we overwrite them with their decoded values
		for (final String letter in LETTERS) {
			final dynamic schedule = data [letter];
			if (schedule is String) 			
				data [letter] = jsonDecode(schedule);
		}
		return Student (
		schedule: {
			Letters.A: Schedule.fromData (data ["A"]),
			Letters.B: Schedule.fromData (data ["B"]),
			Letters.C: Schedule.fromData (data ["C"]),
			Letters.E: Schedule.fromData (data ["E"]),
			Letters.F: Schedule.fromData (data ["F"]),
			Letters.M: Schedule.fromData (data ["M"]),
			Letters.R: Schedule.fromData (data ["R"]),
		},
		// These entries are not actually in the database yet
		// We need to find out how Ramaz stores them
		homeroomDay: Letters.B,  // I think this is standard
		homeroomMeeting: data ["homeroom meeting room"],
		minchaRooms: Map.fromEntries (
			data ["mincha rooms"].entries.map<MapEntry<Letters, String>> (
				(MapEntry<dynamic, dynamic> entry) => MapEntry<Letters, String> (
					stringToLetter (entry.key as String),
					entry.value as String
				)
			)
		),
		// This is aggragated from the "classes" collection in the DB
		subjects: data ["subjects"]
	);}

	List <Period> getPeriods (Day day) {
		final List <Period> result = [];
		final List <PeriodData> periods = schedule [day.letter].periods;
		final Special special = day.special;
		int periodIndex = 0;

		for (int index = 0; index < special.periods.length; index++) {
			final Range range = special.periods [index];
			while ((special?.skip ?? const []).contains(periodIndex + 1))
				periodIndex++; 
			if (special.homeroom == index) result.add (
				Schedule.homeroom (
					range,
					room: getHomeroomMeeting(day)
				)
			); else if (special.mincha == index) result.add (
				Schedule.mincha (range, minchaRooms [day.letter])
			); else {
				final PeriodData period = periods [periodIndex]; 
				if (period == null) result.add (
					Period (
						PeriodData (
							room: null,
							id: -1
						),
						period: (periodIndex + 1).toString(),
						time: range,
					) 
				); else result.add (
					Period (
						period,
						time: range,
						period: (periodIndex + 1).toString()
					) 
				);
				periodIndex++;
			}
		}
		return result;
	}

	String getHomeroomMeeting(Day day) => day.letter == homeroomDay 
		? homeroomMeeting : null;
}