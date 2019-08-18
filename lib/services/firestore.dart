import "package:cloud_firestore/cloud_firestore.dart";
import "dart:async" show Future;

import "package:ramaz/services/auth.dart" as Auth;

import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/student.dart";
import "package:ramaz/data/note.dart";

const String STUDENTS = "students";
const String CLASSES = "classes";
const String CALENDAR = "calendar";
const String FEEDBACK = "feedback";
const String NOTES = "notes";

final Firestore firestore = Firestore.instance;
final CollectionReference students = firestore.collection(STUDENTS);
final CollectionReference classes = firestore.collection (CLASSES);
final CollectionReference feedback = firestore.collection (FEEDBACK);
final CollectionReference calendar = firestore.collection(CALENDAR);
final CollectionReference notes = firestore.collection (NOTES);

Future<Map<String, dynamic>> getStudent (String username) async => 
	(await students.document(username).get()).data;

Future<Map<String, dynamic>> getClass (String id) async => 
	(await classes.document(id).get()).data;

Future<Map<String, Map<String, dynamic>>> getClasses(Student student) async {
	Set<String> ids = {};
	for (final List<PeriodData> schedule in student.schedule.values) {
		for (final PeriodData period in schedule) {
			if (period == null) continue;  // skip free periods
			ids.add(period.id);
		}
	}
	ids.add (student.homeroom);
	Map<String, Map<String, dynamic>> result = {};
	for (final String id in ids) 
		result [id] = await getClass(id);
	return result;
}

Future<void> sendFeedback(
	String message, 
	String name,
) => feedback.document().setData({
	"message": message,
	"name": name,
	"timestamp": DateTime.now()
});

Future<Map<String, dynamic>> getMonth() async => (
	await calendar.document(DateTime.now().month.toString()).get()
).data;

Future<List> getNotes(String email) async => 
	(await notes.document(email).get()).data ["notes"];

Future<void> saveNotes(List<Note> notesList) async => notes
	.document(await Auth.getEmail())
	.setData({
		"notes": notesList.map((Note note) => note.toJson()).toList()
	});

