import "package:firebase_admin_interop/firebase_admin_interop.dart" as fb;

import "package:firestore/data.dart";

import "firebase.dart";

class Firestore {
	static final fb.Firestore firestore = app.firestore(); 

	static const String studentsKey = "students";
	static const String calendarKey = "calendar";
	static const String courseKey = "classes";

	static final fb.CollectionReference studentsCollection = 
		firestore.collection(studentsKey);

	static final fb.CollectionReference calendarCollection = 
		firestore.collection(calendarKey);

	static final fb.CollectionReference courseCollection =
		firestore.collection(courseKey);

	static Future<void> upoadStudents(List<Student> students) {
		final fb.WriteBatch batch = firestore.batch();
		for (final Student student in students) {
			batch.setData(
				studentsCollection.document(student.email), 
				fb.DocumentData.fromMap(student.json)
			);
		}
		return batch.commit();
	}

	static Future<void> uploadMonth(int month, List<Day> calendar) => (
		firestore.batch()
			..setData(
			calendarCollection.document(month.toString()),
			fb.DocumentData.fromMap({
				"calendar": [
					for (final Day day in calendar)
						day.json
				]
			})
		)
	).commit();

	static Future<void> uploadCourses(List<Subject> courses) async {
		final List<fb.WriteBatch> batches = [];
		int count = 0;
		for (final Subject subject in courses) {
			if (count % 500 == 0) {
				batches.add(firestore.batch());
			}
			batches [batches.length - 1].setData(
				courseCollection.document(subject.id),
				fb.DocumentData.fromMap(subject.json),
			);
			count++;
		}
	}
}