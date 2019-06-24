import "package:flutter/foundation.dart";

// TODO: move this import into Reader

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
	// final Map <Letters, String> minchaRooms;
	final Map<int, Subject> subjects;

	const Student ({
		@required this.schedule,
		@required this.homeroomDay,
		@required this.homeroomMeeting,
		// @required this.minchaRooms,
		@required this.subjects
	});

	factory Student.fromData (Map<String, dynamic> data) {
		return Student (
		schedule: {
			Letters.A: Schedule.fromJson (data ["A"]),
			Letters.B: Schedule.fromJson (data ["B"]),
			Letters.C: Schedule.fromJson (data ["C"]),
			Letters.E: Schedule.fromJson (data ["E"]),
			Letters.F: Schedule.fromJson (data ["F"]),
			Letters.M: Schedule.fromJson (data ["M"]),
			Letters.R: Schedule.fromJson (data ["R"]),
		},
		// These entries are not actually in the database yet
		// We need to find out how Ramaz stores them
		homeroomDay: Letters.B,  // I think this is standard
		homeroomMeeting: data ["homeroom meeting room"],
		// minchaRooms: Map.fromEntries (
		// 	data ["mincha rooms"].entries.map<MapEntry<Letters, String>> (
		// 		(MapEntry<dynamic, dynamic> entry) => MapEntry<Letters, String> (
		// 			stringToLetter (entry.key as String),
		// 			entry.value as String
		// 		)
			// )
		// ),
		// This is aggragated from the "classes" collection in the DB
		subjects: data ["subjects"]
	);}

	List <Period> getPeriods (Day day) {
		if (day.letter == null) return null;
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
				// Schedule.mincha (range, minchaRooms [day.letter])
				Schedule.mincha(range)
			); else {
				final PeriodData period = periods [periodIndex]; 
				if (period == null) result.add (
					Period (
						PeriodData (
							room: null,
							id: null
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