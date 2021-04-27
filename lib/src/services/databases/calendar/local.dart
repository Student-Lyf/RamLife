import "../../idb.dart";

import "interface.dart";

/// Handles calendar data on the device. 
/// 
/// The calendar is held in an object store where they key is the month numbered
/// 1-12. The schedules are in another object store where the names are key.
class LocalCalendar implements CalendarInterface {
	@override
	Future<Map> getMonth(int month) => Idb.instance.database.throwIfNull(
		storeName: Idb.calendarStoreName,
		key: month,
		message: "Cannot find $month in local database",
	);

	@override
	Future<void> setMonth(int month, Map json) => Idb.instance.database.update(
		storeName: Idb.calendarStoreName,
		value: json,
	);

	@override
	Future<List<Map>> getSchedules() => Idb.instance.database
		.getAll(Idb.scheduleStoreName);

	@override
	Future<void> setSchedules(List<Map> json) async {
		for (final Map schedule in json) {
			await Idb.instance.database.update(
				storeName: Idb.scheduleStoreName,
				value: schedule,
			);
		}
	}
}
