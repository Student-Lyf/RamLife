import "package:ramaz/data.dart";
export "package:ramaz/data.dart";

/// Defines methods for the calendar data. 
abstract class CalendarInterface {
	/// Gets one month from the calendar. 
	/// 
	/// [month] is 1-12, not 0-11. The returned list contains a JSON form of each 
	/// day. Null days represent no school.
	Future<List<Json?>> getMonth(int month);

	/// Saves a month of the calendar. 
	/// 
	/// [month] is 1-12, not 0-11. See the [getMonth] for the structure of [json].
	Future<void> setMonth(int month, List<Json?> json);

	/// Gets all the schedules in the calendar. 
	/// 
	/// So far, schedules cannot be handled individually, since there is no way
	/// to know which schedules need to be used and which don't. 
	Future<List<Json>> getSchedules();

	/// Saves all the schedules. 
	Future<void> setSchedules(List<Json> json);
}
