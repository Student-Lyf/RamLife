import "../../firestore.dart";
import "../../idb.dart";

import "interface.dart";

/// Handles calendar data in the cloud.
/// 
/// Each month is in a document labeled with the month number, from 1-12. The
/// actual data itself is in `calendar` field, alongside the `month` field.
/// 
/// The schedules are in a document called `schedules`, under the field
/// `schedules`.
class CloudCalendar implements CalendarInterface {
	/// The calendar collection in Firestore.
	static final CollectionReference<Map<String, dynamic>> calendar = Firestore
		.instance.collection("calendar");

	/// The document inside [calendar] that holds the schedules.
	static final DocumentReference<Map<String, dynamic>> schedules = 
		calendar.doc("schedules");

	@override
	Future<List<Json?>> getMonth(int month) async {
		final json = await calendar.doc(month.toString())
			.throwIfNull("Month $month not found in cloud database");
		return List<Json?>.from(json ["calendar"]);
	}

	@override
	Future<void> setMonth(int month, List<Json?> json) => calendar
		.doc(month.toString()).set({"month": month, "calendar": json});

	@override
	Future<List<Json>> getSchedules() async => List<Json>.from(
		(await schedules.throwIfNull("Cannot find schedules")) ["schedules"],
	);

	@override
	Future<void> setSchedules(List<Json> json) => schedules
		.set({"schedules": json});
}

/// Handles calendar data on the device. 
/// 
/// The calendar is held in an object store where they key is the month numbered
/// 1-12. 
/// 
/// The schedules are in another object store where the names are the keys.
class LocalCalendar implements CalendarInterface {
	@override
	Future<List<Json?>> getMonth(int month) async {
		final json = await Idb.instance.throwIfNull(
			storeName: Idb.calendarStoreName,
			key: month,
			message: "Cannot find $month in local database",
		);
		return List<Json?>.from(json ["calendar"]);
	}

	@override
	Future<void> setMonth(int month, List<Json?> json) => Idb.instance.update(
		storeName: Idb.calendarStoreName,
		value: {"month": month, "calendar": json},
	);

	@override
	Future<List<Json>> getSchedules() => Idb.instance
		.getAll(Idb.scheduleStoreName);

	@override
	Future<void> setSchedules(List<Json> json) async {
		for (final schedule in json) {
			await Idb.instance.update(
				storeName: Idb.scheduleStoreName,
				value: schedule,
			);
		}
	}
}
