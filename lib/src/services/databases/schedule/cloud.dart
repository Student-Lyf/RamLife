import "package:cloud_firestore/cloud_firestore.dart";

import "../../firestore.dart";

import "interface.dart";

/// Handles schedule date in the cloud. 
class CloudSchedule implements ScheduleInterface {
	/// The courses collection in Firestore. 
	static final CollectionReference courses = Firestore.instance
		.collection("classes");

	@override 
	Future<Map> getCourse(String id) => courses.doc(id)
		.throwIfNull("Course $id not found");

	@override
	Future<void> setCourse(String id, Map json) async { }
}
