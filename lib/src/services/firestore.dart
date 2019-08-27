import "package:cloud_firestore/cloud_firestore.dart" as FB;
import "dart:async" show Future;

import "auth.dart";

import "package:ramaz/data.dart";

class Firestore {
	static const String STUDENTS = "students";
	static const String CLASSES = "classes";
	static const String CALENDAR = "calendar";
	static const String FEEDBACK = "feedback";
	static const String NOTES = "notes";
	static const String SPORTS = "sports";

	static final FB.Firestore firestore = FB.Firestore.instance;
	static final FB.CollectionReference students = firestore.collection(STUDENTS);
	static final FB.CollectionReference classes = firestore.collection (CLASSES);
	static final FB.CollectionReference feedback = firestore.collection (FEEDBACK);
	static final FB.CollectionReference calendar = firestore.collection(CALENDAR);
	static final FB.CollectionReference notes = firestore.collection (NOTES);
	static final FB.CollectionReference sports = firestore.collection(SPORTS);

	static Future<Map<String, dynamic>> getStudent (String username) async => 
		(await students.document(username).get()).data;

	static Future<Map<String, dynamic>> getClass (String id) async => 
		(await classes.document(id).get()).data;

	static Future<Map<String, Map<String, dynamic>>> getClasses(Student student) async {
		Set<String> ids = {};
		for (final List<PeriodData> schedule in student.schedule.values) {
			for (final PeriodData period in schedule) {
				if (period == null) continue;  // skip free periods
				else if (period.id == null) continue;
				ids.add(period.id);
			}
		}
		ids.add (student.homeroom);
		Map<String, Map<String, dynamic>> result = {};
		for (final String id in ids) 
			result [id] = await getClass(id);
		return result;
	}

	static Future<void> sendFeedback(
		String message, 
		String name,
	) => feedback.document().setData({
		"message": message,
		"name": name,
		"timestamp": DateTime.now()
	});

	static Future<Map<String, dynamic>> getMonth() async => (
		await calendar.document(DateTime.now().month.toString()).get()
	).data;

	static Future<Map<String, dynamic>> getNotes(String email) async => 
		(await notes.document(email).get()).data;

	static Future<void> saveNotes(List<Note> notesList, List<int> readNotes) async => notes
		.document(await Auth.getEmail())
		.setData({
			"notes": notesList.map((Note note) => note.toJson()).toList(),
			"read": readNotes
		});

	static Future<List<Map<String, dynamic>>> getSports() async => 
		List<Map<String, dynamic>>.from (
			(await sports.document("sports").get()).data ["games"].map (
				(json) => Map<String, dynamic>.from(json)
			).toList()
		);
}