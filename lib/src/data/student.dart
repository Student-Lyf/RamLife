library student_dataclasses;

import "package:flutter/foundation.dart";
import "dart:convert" show JsonUnsupportedObjectError;

import "schedule.dart";
import "times.dart";

/// A representation of a student. 
/// 
/// This object holds their schedule, and is a convenience class for getting 
/// their schedule, as well as some other noteable data, such as when and where
/// to meet for homeroom. 
@immutable
class Student {
	/// This student's schedule.
	/// 
	/// Each key is a different day, and the value is a list of periods. 
	/// See [Letters] and [PeriodData] for more information.
	final Map <Letters, List<PeriodData>> schedule;

	/// The rooom for this students homeroom. 
	/// 
	/// This is not stored with other [PeriodData]s in the database, 
	/// so it is more convenient to extract it and keep here. 
	final String homeroomLocation;

	/// The id of this student's advisory group. 
	/// 
	/// This can be used to get the student's advisor. 
	final String homeroom;

	/// `const` constructor for a student.
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

	/// Creates a student from a JSON object.
	/// 
	/// Needs to be a factory so there can be proper error checking.
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

	/// Returns the schedule for this student on a given day. 
	/// 
	/// Iterates over the schedule for [day] in [schedule], and converts the
	/// [PeriodData]s to [Period] objects using the [Range]s in [Day.special]. 
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
						PeriodData.free,
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

	/// Returns a [PeriodData] for this student's homeroom period on a given day.
	PeriodData getHomeroom(Day day) => day.letter == Letters.B 
		? PeriodData (room: homeroomLocation, id: homeroom) 
		: PeriodData.free;
}
