import "../../firestore.dart";
import "../../idb.dart";

import "interface.dart";

/// Handles schedule date in the cloud. 
/// 
/// Each course is its own document in the `classes` collection. The keys are
/// the courses section-IDs, so they're really "sections", not courses.
class CloudSchedule implements ScheduleInterface {
	/// The courses collection in Firestore. 
	static final CollectionReference<Json> courses = Firestore.instance
		.collection("classes");

	@override 
	Future<Json> getCourse(String id) => courses.doc(id)
		.throwIfNull("Course $id not found");

	@override
	Future<void> setCourse(String id, Json json) async { }
}

/// Handles schedule data on the device. 
/// 
/// Each course is its own record in the `sections` object store, whose
/// keypath is the `id` field (the section-IDs).
class LocalSchedule implements ScheduleInterface {
	@override 
	Future<Json?> getCourse(String id) => Idb.instance
		.get(Idb.sectionStoreName, id);

	@override
	Future<void> setCourse(String id, Json json) => Idb.instance
		.update(storeName: Idb.sectionStoreName, value: json);
}
