import "package:flutter/foundation.dart";
import "dart:convert" show JsonUnsupportedObjectError;

import "schedule.dart";
import "times.dart";

class Student {
	final Map <Letters, List<PeriodData>> schedule;
	final String homeroomLocation, homeroom;

	const Student ({
		@required this.schedule,
		@required this.homeroomLocation,
		@required this.homeroom,
	});

	@override String toString() => schedule.toString();
	@override operator == (other) => (
		other is Student && 
		other.schedule == schedule && 
		other.homeroomLocation == homeroomLocation
	);

	factory Student.fromJson (Map<String, dynamic> json) {
		// Fun Fact: ALl this is error checking. 
		// Your welcome. 

		// Check for null homeroom
		const String homeroomLocationKey = "homeroom meeting room";
		if (!json.containsKey(homeroomLocationKey)) 
			throw JsonUnsupportedObjectError(
				json, cause: "No homeroom location present"
			);
		final String homeroomLocation = json [homeroomLocationKey];
		if (homeroomLocation == null) 
			throw ArgumentError.notNull(homeroomLocationKey);

		const String homeroomKey = "homeroom";
		if (!json.containsKey (homeroomKey)) 
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
			homeroomLocation: homeroomLocation,
			homeroom: homeroom,
			schedule: {
				Letters.A: PeriodData.getList (json ["A"]),
				Letters.B: PeriodData.getList (json ["B"]),
				Letters.C: PeriodData.getList (json ["C"]),
				Letters.E: PeriodData.getList (json ["E"]),
				Letters.F: PeriodData.getList (json ["F"]),
				Letters.M: PeriodData.getList (json ["M"]),
				Letters.R: PeriodData.getList (json ["R"]),
			},
		);
	}

	List <Period> getPeriods (Day day) {
		final List <Period> result = [];
		if (!day.school) return result;
		final List <PeriodData> periods = schedule [day.letter];
		final Special special = day.special;
		int periodIndex = 0;

		for (int index = 0; index < special.periods.length; index++) {
			final Range range = special.periods [index];
			while ((special?.skip ?? const []).contains(periodIndex + 1))
				periodIndex++; 
			if (special.homeroom == index) result.add (
				Period (
					getHomeroom(day),
					time: range,
					period: "Homeroom",
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

	PeriodData getHomeroom(Day day) => day.letter == Letters.B 
		? PeriodData (room: homeroomLocation, id: homeroom) 
		: PeriodData.free();
}