import "package:flutter/foundation.dart";
import "dart:convert" show JsonUnsupportedObjectError;

import "schedule.dart";
import "times.dart";

class Student {
	final Map <Letters, Schedule> schedule;
	final String homeroom;

	const Student ({
		@required this.schedule,
		@required this.homeroom,
	});

	@override String toString() => schedule.toString();
	@override operator == (other) => (
		other is Student && other.schedule == schedule && other.homeroom == homeroom
	);

	factory Student.fromJson (Map<String, dynamic> json) {
		// Fun Fact: ALl this is error checking. 
		// Your welcome. 

		// Check for null homeroom
		const String homeroomKey = "homeroom meeting room";
		if (!json.containsKey(homeroomKey)) 
			throw JsonUnsupportedObjectError(json, cause: "No homeroom present");
		final String homeroom = json [homeroomKey];
		if (homeroom == null) throw ArgumentError.notNull(homeroomKey);

		// Check for null schedules
		const List<String> letters = ["A", "B", "C", "E", "F", "M", "R"];
		for (final String letter in letters) {
			if (!json.containsKey (letter)) throw JsonUnsupportedObjectError(
				json, cause: "Cannot find letter $letter"
			);
			if (json [letter] == null) 
				throw ArgumentError.notNull ("$letter has no schedule");
		}
		
		// Real code starts here
		return Student (
			homeroom: homeroom,
			schedule: {
				Letters.A: Schedule.fromJson (json ["A"]),
				Letters.B: Schedule.fromJson (json ["B"]),
				Letters.C: Schedule.fromJson (json ["C"]),
				Letters.E: Schedule.fromJson (json ["E"]),
				Letters.F: Schedule.fromJson (json ["F"]),
				Letters.M: Schedule.fromJson (json ["M"]),
				Letters.R: Schedule.fromJson (json ["R"]),
			},
		);
	}

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
				Period.homeroom (
					range,
					room: getHomeroomMeeting(day)
				)
			); else if (special.mincha == index) result.add (
				Period.mincha(range)
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

	String getHomeroomMeeting(Day day) => day.letter == Letters.B 
		? homeroom : null;
}