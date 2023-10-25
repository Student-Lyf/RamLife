import "package:ramaz/data.dart";
export "package:ramaz/data.dart";

/// Defines methods for the reminder data. 
/// 
/// Reminders are indexed by a unique ID that doesn't change. This ID should be
/// placed in `json ["id"]`.
abstract class RemindersInterface {
	/// Gets all the user's reminders.
	Future<List<Json>> getAll();

	/// Updates a single reminder.
	/// 
	/// If the reminder already exists, it will be overwritten.
	Future<void> set(Json json);

	/// Deletes the reminder at the given id.
	Future<void> delete(String id);	
}
