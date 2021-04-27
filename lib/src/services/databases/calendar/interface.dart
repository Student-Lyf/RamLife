/// Defines methods for the calendar data. 
abstract class CalendarInterface {
	/// Gets one month from the calendar. 
	/// 
	/// [month] is 1-12, not 0-11. The returned JSON has two fields, `calendar`
	/// and `month`. `calendar` is a list of JSON representing days.
	Future<Map> getMonth(int month);

	/// Saves a month of the calendar. 
	/// 
	/// [month] is 1-12, not 0-11. See the [getMonth] for the structure of [json].
	Future<void> setMonth(int month, Map json);

	/// Gets all the schedules in the calendar. 
	/// 
	/// So far, schedules cannot be handled individually, since there is no way
	/// to know which schedules need to be used and which don't. 
	Future<List<Map>> getSchedules();

	/// Saves all the schedules. 
	Future<void> setSchedules(List<Map> json);
}
