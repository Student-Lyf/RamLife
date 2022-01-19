import "package:meta/meta.dart";

import "package:ramaz/constants.dart";

import "period.dart";
import "time.dart";

/// A description of the time allotment for a day. 
/// 
/// Some days require different time periods, or even periods that 
/// are skipped altogether, as well as homeroom and Mincha movements.
/// This class helps facilitate that. 
@immutable
class Schedule {
	/// The list of schedules defined in the calendar. 
	/// 
	/// This is a rare exception where the database and data layers intermingle. 
	/// Schedules are defined by their name, but their values exist elsewhere in 
	/// the database. So, the data layer needs some lookup method in order to be 
	/// useful. Specifically, [Day.fromJson()] needs to work _somehow_.
	/// 
	/// `late` means that this value is initialized after startup, but the value 
	/// cannot be used until it is. This means that we need to be careful not to 
	/// access this value until we can be sure that the database values were 
	/// synced. Dart will throw a runtime error otherwise, so it should be fairly
	/// simple to catch problems during testing.
	static late List<Schedule> schedules;

	/// The name of this schedule. 
	final String name;

	/// A Map of weekdays to their default schedule
	static late Map<String, Schedule> defaults;

	/// The time allotments for the periods. 
	final List<Period> periods;

	/// A const constructor.
	const Schedule({
		required this.name,
		required this.periods,
	});

	/// Returns a new [Schedule] from a JSON value. 
	/// 
	/// The JSON must have: 
	/// 
	/// - a "name" field, which should be a string. See [name].
	/// - a "periods" field, which should be a list of [Period] JSON objects. 
	Schedule.fromJson(Map json) :
		name = json ["name"],  // name
		periods = [  // list of periods
			for (final dynamic jsonElement in json ["periods"]) 
				Period.fromJson(jsonElement)
		];
	@override 
	String toString() => name;

	@override
	int get hashCode => name.hashCode;

	@override 
	bool operator == (dynamic other) => other is Schedule && 
		other.name == name;

	/// Returns a JSON representation of this schedule.
	Map toJson() => {
		"name": name,
		"periods": [
			for (final Period period in periods) 
				period.toJson(),
		],
	};


}
