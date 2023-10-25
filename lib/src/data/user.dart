import "package:meta/meta.dart";

import "contact_info.dart";
import "schedule/advisory.dart";
import "schedule/day.dart";
import "schedule/period.dart";
import "schedule/time.dart";

import "types.dart";

/// Scopes for administrative privileges.
/// 
/// Admin users use these scopes to determine what they can read/write.
enum AdminScope {
	/// The admin can access and modify the calendar.
	calendar, 

	/// The admin can access and modify student schedules.
	schedule,

	/// The admin can create and update sports games.
	sports,
}

/// Maps Strings to [AdminScope]s. 
AdminScope parseAdminScope(String scope) {
	switch (scope) {
		case "calendar": return AdminScope.calendar;
		case "schedule": return AdminScope.schedule;
		case "sports": return AdminScope.sports;
		default: throw ArgumentError("Invalid admin scope: $scope");
	}
}

/// Maps [AdminScope]s to Strings. 
String adminScopeToString(AdminScope scope) {
	switch (scope) {
		case AdminScope.calendar: return "calendar";
		case AdminScope.schedule: return "schedule";
		case AdminScope.sports: return "sports";
	}
}

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
	final Map<String, List<PeriodData?>> schedule;

	/// The advisory for this user. 
	final Advisory? advisory;

	/// This user's contact information. 
	final ContactInfo contactInfo;

	/// The grade this user is in. 
	/// 
	/// This property is null for faculty. 
	final Grade? grade;

	/// The IDs of the clubs this user attends.
	final List<String> registeredClubs; 

	/// The possible day names for this user's schedule.
	/// 
	/// These will be used as the keys for [schedule].
	final Iterable<String> dayNames;

	/// Creates a new user.
	const User({
		required this.schedule,
		required this.contactInfo,
		required this.registeredClubs,
		required this.dayNames,
		this.grade,
		this.advisory,
	});

	/// Gets a value from JSON, throwing if null.
	/// 
	/// This function is needed since null checks don't run on dynamic values.
	static dynamic safeJson(Json json, String key) {
		final dynamic value = json [key];
		if (value == null) {
			throw ArgumentError.notNull(key);
		} else {
			return value;
		}
	}

	/// Creates a new user from JSON. 
	User.fromJson(Json json) : 
		dayNames = List<String>.from(safeJson(json, "dayNames")),
		schedule = {
			for (final String dayName in safeJson(json, "dayNames"))
				dayName: PeriodData.getList(json [dayName]),
		},
		advisory = json ["advisory"] == null ? null : Advisory.fromJson(
			Map.from(safeJson(json, "advisory")),
		),
		contactInfo = ContactInfo.fromJson(
			Map.from(safeJson(json, "contactInfo")),
		),
		grade = json ["grade"] == null ? null : intToGrade [safeJson(json, "grade")],
		registeredClubs = List<String>.from(json ["registeredClubs"] ?? []);

	/// Gets the unique section IDs for the courses this user is enrolled in.
	/// 
	/// For teachers, these will be the courses they teach. 
	Set<String> get sectionIDs => {
		for (final List<PeriodData?> daySchedule in schedule.values)
			for (final PeriodData? period in daySchedule)
				if (period != null)
					period.id,
	};

	/// Computes the periods, in order, for a given day. 
	/// 
	/// This method converts the [PeriodData]s in [schedule] into [Period]s using 
	/// [Day.schedule]. [PeriodData] objects are specific to the user's schedule, 
	/// whereas the times of the day [Range]s are specific to the calendar. 
	List<Period> getPeriods(Day day) => [
		for (final Period period in day.schedule.periods) period.copyWith(
			int.tryParse(period.name) == null ? null 
				: schedule [day.name]! [int.parse(period.name) - 1],
		),
	];
}
