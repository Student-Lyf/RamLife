import "../../idb.dart";

import "interface.dart";

/// Handles schedule data on the device. 
class LocalSchedule implements ScheduleInterface {
	@override 
	Future<Map?> getCourse(String id) => Idb.instance
		.get(Idb.sectionStoreName, id);

	@override
	Future<void> setCourse(String id, Map json) => Idb.instance
		.add(storeName: Idb.sectionStoreName, value: json);
}
