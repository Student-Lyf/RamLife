import "package:ramaz/data.dart";
export "package:ramaz/data.dart";

/// Defines methods for the schedule data.
abstract class ScheduleInterface {
	/// Gets a course from the database. 
	Future<Json?> getCourse(String id);

	/// Saves a course into the database. 
	Future<void> setCourse(String id, Json json);
}
