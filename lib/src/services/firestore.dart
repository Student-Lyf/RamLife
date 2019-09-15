import "package:cloud_firestore/cloud_firestore.dart" as FB;

import "auth.dart";

import "package:ramaz/data.dart";

/// An abstraction wrapper around Cloud Firestore. 
/// 
/// This class only handles raw data transfer to and from Cloud Firestore.
/// Do not attempt to use dataclasses here, as that will create a dependency
/// between this library and the data library. 
class Firestore {
	/// The name for the student schedule collection
	static const String STUDENTS = "students";

	/// The name of the classes collection
	static const String CLASSES = "classes";

	/// The name of the calendar collection
	static const String CALENDAR = "calendar";
	
	/// The name of the feedback collection
	static const String FEEDBACK = "feedback";

	/// The name of the notes collection
	static const String NOTES = "notes";

	static final FB.Firestore _firestore = FB.Firestore.instance;
	static final FB.CollectionReference _students = _firestore.collection(STUDENTS);
	static final FB.CollectionReference _classes = _firestore.collection (CLASSES);
	static final FB.CollectionReference _feedback = _firestore.collection (FEEDBACK);
	static final FB.CollectionReference _calendar = _firestore.collection(CALENDAR);
	static final FB.CollectionReference _notes = _firestore.collection (NOTES);

	/// Downloads the student's document in the student collection.
	static Future<Map<String, dynamic>> getStudent (String username) async => 
		(await _students.document(username).get()).data;

	/// Downloads the class document in the classes collection.
	static Future<Map<String, dynamic>> getClass (String id) async => 
		(await _classes.document(id).get()).data;

	/// Gets all class documents for a students schedule
	/// 
	/// This function goes over the student's schedule and keeps a record 
	/// of the unique section IDs and queries the database for them afterwards 
	/// using [getClass].
	/// 
	/// This function should be re-written to only accept a list of IDs
	/// instead of a student, as this creates a dependency between this 
	/// library and the data library.
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

	/// Submits feedback. 
	/// 
	/// The feedback collection is write-only, and can only be accessed by admins.
	static Future<void> sendFeedback(
		Map<String, dynamic> json
	) => _feedback.document().setData(json);

	/// Downloads the calendar for the current month. 
	static Future<Map<String, dynamic>> getMonth() async => (
		await _calendar.document(DateTime.now().month.toString()).get()
	).data;

	/// Downloads the notes for the user. 
	/// 
	/// At least for now, these are stored in a spearate collection than
	/// the student profile data. This choice was made since notes are 
	/// updated frequently and this saves the system from processing the
	/// student's schedule every time this happens. 
	static Future<Map<String, dynamic>> getNotes(String email) async => 
		(await _notes.document(email).get()).data;

	/// Uploads the user's notes to the database. 
	/// 
	/// This function saves the notes along with a record of the notes that
	/// were already read. Those notes will be deleted once they are irrelevant.
	/// 
	/// This should be re-written to only accept a list of JSON elements, as 
	/// this creates a dependency between this library and the data library.
	/// This should also probably not persist the read notes in the database 
	/// (ie, keep them local).
	static Future<void> saveNotes(List<Note> notesList, List<int> readNotes) async => _notes
		.document(await Auth.getEmail())
		.setData({
			"notes": notesList.map((Note note) => note.toJson()).toList(),
			"read": readNotes
		});
}
