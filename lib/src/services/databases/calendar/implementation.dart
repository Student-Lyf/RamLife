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
	Future<List<Map?>> getMonth(int month) async {
		final Map json = await calendar.doc(month.toString())
			.throwIfNull("Month $month not found in cloud database");
		return List<Map?>.from(json ["calendar"]);
	}

	@override
	Future<void> setMonth(int month, List<Map?> json) => calendar
		.doc(month.toString()).set({"month": month, "calendar": json});

	@override
	Future<List<Map>> getSchedules() async => List<Map>.from(
		(await schedules.throwIfNull("Cannot find schedules")) ["schedules"]
	);
	@override
	Future<Map<String, String>> getDefaultSchedules() async => Map.from(
			(await schedules.throwIfNull("Cannot find defaults")) ["schedules"]);
	@override
	Future<void> setSchedules(List<Map> json) => schedules
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
	Future<List<Map?>> getMonth(int month) async {
		final Map json = await Idb.instance.throwIfNull(
			storeName: Idb.calendarStoreName,
			key: month,
			message: "Cannot find $month in local database",
		);
		return List<Map?>.from(json ["calendar"]);
	}

	@override
	Future<void> setMonth(int month, List<Map?> json) => Idb.instance.update(
		storeName: Idb.calendarStoreName,
		value: {"month": month, "calendar": json},
	);

	@override
	Future<List<Map>> getSchedules() => Idb.instance
		.getAll(Idb.scheduleStoreName);

	@override
	Future<Map<String, String>> getDefaultSchedules() => Idb.instance
			.get("schedules","Monday") as Future<Map<String, String>>;
	@override
	Future<void> setSchedules(List<Map> json) async {
		for (final Map schedule in json) {
			await Idb.instance.update(
				storeName: Idb.scheduleStoreName,
				value: schedule,
			);
		}
	}
}
