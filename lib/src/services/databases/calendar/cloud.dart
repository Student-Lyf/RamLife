import "../../firestore.dart";

import "interface.dart";

/// Handles calendar data in the cloud.
/// 
/// Each month is in a document labeled with the month number, from 1-12. 
/// The schedules are in a document called `schedules`, under the field
/// `schedules`.
class CloudCalendar implements CalendarInterface {
	/// The calendar collection in Firestore.
	static final CollectionReference calendar = Firestore.instance
		.collection("calendar");

	/// The document inside [calendar] that holds the schedules.
	static final DocumentReference schedules = calendar.doc("schedules");

	@override
	Future<Map> getMonth(int month) => calendar.doc(month.toString())
		.throwIfNull("Month $month not found in cloud database");

	@override
	Future<void> setMonth(int month, Map json) => calendar.doc(month.toString())
		.set(Map<String, dynamic>.from(json));

	@override
	Future<List<Map>> getSchedules() async => List<Map>.from(
		(await schedules.throwIfNull("Cannot find schedules")) ["schedules"]
	);

	@override
	Future<void> setSchedules(List<Map> json) => schedules
		.set({"schedules": json});
}
