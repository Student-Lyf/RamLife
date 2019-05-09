import "package:cloud_firestore/cloud_firestore.dart";
import "dart:async" show Future;

import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/student.dart";

const String STUDENTS = "students";
const String CLASSES = "classes";

final Firestore firestore = Firestore.instance;
final CollectionReference students = firestore.collection(STUDENTS);
final CollectionReference classes = firestore.collection (CLASSES);
final CollectionReference feedback = firestore.collection ("feedback");

Future<DocumentSnapshot> getStudent (String username) async => 
	await students.document(username).get();

Future<DocumentSnapshot> getClass (int id) async => 
	await classes.document(id.toString()).get();

Future<Map<int, Map<String, dynamic>>> getClasses(Student student) async {
	Set<int> ids = {};
	for (final Schedule schedule in student.schedule.values) {
		for (final PeriodData period in schedule.periods) {
			if (period == null) continue;  // skip free periods
			ids.add(period.id);
		}
	}
	Map<int, Map<String, dynamic>> result = {};
	for (final int id in ids) 
		result [id] = (await getClass(id)).data;
	return result;
}

Future<void> sendFeedback(String message, String uid) => feedback
	.document().setData({
		"message": message,
		"uid": uid,
		"timestamp": DateTime.now()
	});
