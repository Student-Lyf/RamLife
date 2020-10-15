import "package:meta/meta.dart";

import "contact_info.dart";
import "schedule/advisory.dart";
import "schedule/day.dart";
import "schedule/period.dart";
import "schedule/special.dart";
import "schedule/time.dart";

/// What grade the user is in. 
/// 
/// The [User.grade] field could be an `int`, but by specifying the exact
/// possible values, we avoid any possible errors, as well as possibly cleaner
/// code.  
/// 
/// Faculty users can have [User.grade] be null. 
enum Grade {
	/// A Freshman. 
	freshman, 

	/// A Sophomore. 
	sophomore,

	/// A Junior. 
	junior,

	/// A Senior. 
	senior
}

/// Maps grade numbers to a [Grade] type. 
Map<int, Grade> intToGrade = {
	9: Grade.freshman,
	10: Grade.sophomore,
	11: Grade.junior,
	12: Grade.senior,
};

/// Represents a user and all their data. 
/// 
/// This objects includes data like the user's schedule, grade, list of clubs, 
/// and more. 
@immutable
class User {
	/// The user's schedule. 
	/// 
	/// Each key is a different day, and the values are list of periods in that  
	/// day. Possible key values are defined by [dayNames].
	/// 
	/// Periods may be null to indicate free periods (or, in the case of faculty,
	/// periods where they don't teach).
	final Map<String, List<PeriodData>> schedule;

	/// The advisory for this user. 
	// TODO: work this into the logic. 
	final Advisory advisory;

	/// This user's contact information. 
	final ContactInfo contactInfo;

	/// The grade this user is in. 
	/// 
	/// This property is null for faculty. 
	final Grade grade;

	/// The IDs of the clubs this user attends.
	/// 
	/// TODO: decide if this is relevant for captains.
	final List<String> registeredClubs; 

	/// The possible day names for this user's schedule.
	/// 
	/// These will be used as the keys for [schedule].
	final Iterable<String> dayNames;

	/// Creates a new user.
	const User({
		@required this.schedule,
		@required this.advisory,
		@required this.contactInfo,
		@required this.grade,
		@required this.registeredClubs,
		@required this.dayNames,
	});

	/// Creates a new user from JSON. 
	User.fromJson(Map<String, dynamic> json) : 
		dayNames = List<String>.from(json ["dayNames"]),
		schedule = {
			for (final String dayName in <String>[...json ["dayNames"]])
				dayName: PeriodData.getList(json [dayName])
		},
		advisory = Advisory.fromJson(
			Map<String, dynamic>.from(json ["advisory"])
		),
		contactInfo = ContactInfo.fromJson(
			Map<String, dynamic>.from(json ["contactInfo"])
		),
		grade = intToGrade [json ["grade"]],
		registeredClubs = List<String>.from(json ["registeredClubs"]);

	/// Gets the unique section IDs for the courses this user is enrolled in.
	/// 
	/// For teachers, these will be the courses they teach. 
	Set<String> get sectionIDs => {
		for (final List<PeriodData> daySchedule in schedule.values)
			for (final PeriodData period in daySchedule)
				if (period?.id != null)
					period.id
	};

	/// Computes the periods, in order, for a given day. 
	/// 
	/// This method converts the [PeriodData]s in [schedule] into [Period]s using 
	/// [Day.special]. [PeriodData] objects are specific to the user's schedule, 
	/// whereas the times of the day [Range]s are specific to the calendar. 
	/// 
	/// See [Special] for an explanation of the different factors this method
	/// takes into account. 
	/// 
	/// TODO: consolidate behavior on no school. 
	List<Period> getPeriods(Day day) {
		if (!day.school) {
			return [];
		}

		final Special special = day.special;
		int periodIndex = 0;

		Range getTime(int index) => day.isModified 
			? null : special.periods [index];

		return [
			for (int index = 0; index < special.periods.length; index++)
				if (special.homeroom == index) Period(
					PeriodData.free,			
					period: "Homeroom",
					time: getTime(index),
					activity: null,
				) else if (special.mincha == index) Period(
					PeriodData.free,
					period: "Mincha",
					time: getTime(index),
					activity: null,
				) else if (special.skip.contains(index)) Period(
					PeriodData.free,
					period: "Free period",
					time: getTime(index),
					activity: null,
				) else Period(
					schedule [day.name] [periodIndex] ?? PeriodData.free,
					period: (++periodIndex).toString(),
					time: getTime(index),
					activity: null,
				)
		];
	}
}
