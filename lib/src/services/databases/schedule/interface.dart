/// Defines methods for the schedule data.
abstract class ScheduleInterface {
	/// Gets a course from the database. 
	Future<Map?> getCourse(String id);

	/// Saves a course into the database. 
	Future<void> setCourse(String id, Map json);
}
