import "package:flutter/foundation.dart";

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

class Student {
	final int id;
	final Map <Letters, Schedule> schedule;
	final Letters homeroomDay;
	final String homeroomMeeting;
	final Map <Letters, String> minchaRooms;

	const Student ({
		@required this.id,
		@required this.schedule,
		@required this.homeroomDay,
		@required this.homeroomMeeting,
		@required this.minchaRooms
	});

	factory Student.fromData (Map<String, dynamic> data) => Student (
		id: data ["id"],
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
		minchaRooms: data ["mincha rooms"].entries.map (
			(MapEntry<String, String> entry) => MapEntry (
				stringToLetter (entry.key),
				entry.value
			)
		)
	);

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