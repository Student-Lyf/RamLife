import "package:flutter/foundation.dart";
import "schedule.dart";
import "times.dart";

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

	List <Period> getPeriods (Day day) {
		final List <Period> result = [];
		final List <PeriodData> periods = schedule [day.letter].periods;
		final Special special = day.special;
		int periodIndex = 0;

		for (int index = 0; index < special.periods.length; index++) {
			final Range range = special.periods [index];
			if (special.homeroom == index) result.add (
				Schedule.homeroom (
					range,
					room: getHomeroomMeeting(day)
				)
			); else if (special.mincha == index) result.add (
				Schedule.mincha (range, minchaRooms [day.letter])
			); else if (schedule [day.letter].freePeriods.any (
				(int index2) => index2 == periodIndex + 1
			)) {
				result.add (
					Period (
						PeriodData (
							room: null,
							id: null
						),
						period: (periodIndex + 1).toString(),
						time: range,
					)
				);
				periodIndex++;
			} else {
				result.add (
					Period (
						periods [periodIndex],
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