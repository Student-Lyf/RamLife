library student_dataclasses;

import "dart:convert" show JsonUnsupportedObjectError;
import "package:flutter/foundation.dart";

import "schedule.dart";
import "times.dart";

/// A representation of a student. 
/// 
/// This object holds their schedule, and is a convenience class for getting 
/// their schedule, as well as some other notable data, such as when and where
/// to meet for homeroom. 
@immutable
class Student {
	/// This student's schedule.
	/// 
	/// Each key is a different day, and the value is a list of periods. 
	/// See [PeriodData] for more information.
	final Map<String, List<PeriodData>> schedule;

	/// The section ID for this student's homeroom; 
	final String homeroomId;

	/// The room location for this student's homeroom;
	final String homeroomLocation;

	/// `const` constructor for a student.
	const Student ({
		@required this.schedule,
		@required this.homeroomId,
		@required this.homeroomLocation,
	});

	@override 
	String toString() => schedule.toString();

	@override
	int get hashCode => schedule.hashCode;

	@override 
	bool operator == (dynamic other) => other is Student && 
		other.schedule == schedule;

	/// Creates a student from a JSON object.
	/// 
	/// Needs to be a factory so there can be proper error checking.
	factory Student.fromJson (Map<String, dynamic> json) {
		// Fun Fact: ALl this is error checking. 
		// Your welcome. 

		// Check for null homeroom
		const String homeroomLocationKey = "homeroom meeting room";
		if (!json.containsKey(homeroomLocationKey)) {
			throw JsonUnsupportedObjectError(
				json, cause: "No homeroom location present"
			);
		}
		final String homeroomLocation = json [homeroomLocationKey];

		const String homeroomKey = "homeroom";
		if (!json.containsKey (homeroomKey)) {
			throw JsonUnsupportedObjectError(json, cause: "No homeroom present");
		}
		final String homeroomId = json [homeroomKey];

		// Real code starts here
		return Student (
			schedule: {
				for (final String dayName in json ["dayNames"])
					dayName: PeriodData.getList(json [dayName])
			},
			homeroomId: homeroomId, 
			homeroomLocation: homeroomLocation,
		);
	}

	/// Returns the schedule for this student on a given day. 
	/// 
	/// Iterates over the schedule for [day] in [schedule], and converts the
	/// [PeriodData]s to [Period] objects using the [Range]s in [Day.special]. 
	/// 
	/// If `day.special` is [Special.modified], every [Period] will have their 
	/// [Period.time] property set to null. 
	List <Period> getPeriods (Day day) {
		if (!day.school) {
			return [];
		} 

		// Get indices for `schedule [day.name]`, keeping skipped periods in mind
		int periodIndex = 0;
		final List<int> periodIndices = [];
		final Map<String, Activity> activities = day.special.activities ?? {};
		// TODO: Remove this line. 
		// final Special special = day.isModified 
		// 	? Day.specials [day.letter] 
		// 	: day.special;
		final Special special = day.special;

		for (int index = 0; index < special.periods.length; index++) {
			// if (special.skip?.contains(index) ?? false)
			// 	periodIndex++;
			// while (special?.skip?.contains(periodIndex + 1) ?? false) {
			// 	periodIndex++;
			// }
			periodIndices.add(
				special.homeroom == index 
				|| special.mincha == index 
				|| (special.skip?.contains(index) ?? false)
					? null
					: periodIndex++
			);
		}
		// Loop over all the periods and assign each one a Period.
		return [
			for (int index = 0; index < special.periods.length; index++) 
				if (special.homeroom == index)
					Period(
						PeriodData.free,
						time: day.isModified ? null : special.periods [index],
						period: "Homeroom",
						activity: activities ["Homeroom"]
					)
				else if (special.mincha == index)
					Period.mincha(
						day.isModified ? null : special.periods [index],
						activity: activities ["Mincha"],
					)
				else if (periodIndices [index] == null) 
					Period(
						PeriodData.free,
						time: day.isModified ? null : special.periods [index],
						period: "Free",
						activity: null,
					)
				else Period(
					schedule [day.name] [periodIndices [index]] ?? PeriodData.free,
					time: day.isModified ? null : special.periods [index],
					period: (periodIndices [index] + 1).toString(),
					activity: activities [(periodIndices [index] + 1).toString()]
				)
		];
	}

	/// Gets the section ids for this student. 
	/// 
	/// This includes every course in every day of the student's schedule,
	/// without taking duplicates. 
	Set<String> getIds() => {
		for (final List<PeriodData> schedule in schedule.values)
			for (final PeriodData period in schedule)
				if (period != null && period != PeriodData.free)  // skip free periods
					period.id
	};
}
