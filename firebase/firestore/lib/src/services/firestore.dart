import "package:firebase_admin_interop/firebase_admin_interop.dart" as fb;

import "package:firestore/data.dart";

import "firebase.dart";

/// A wrapper around Cloud Firestore.
class Firestore {
	/// The firestore instance for [app].
	static final fb.Firestore firestore = app.firestore(); 

	/// The name of the students collection.
	static const String studentsKey = "students";

	/// The name of the calendar collection.
	static const String calendarKey = "calendar";

	/// The name of the course collection.
	static const String courseKey = "classes";

	/// The students collection.
	static final fb.CollectionReference studentsCollection = 
		firestore.collection(studentsKey);

	/// The calendar collection.
	static final fb.CollectionReference calendarCollection = 
		firestore.collection(calendarKey);

	/// The course collection.
	static final fb.CollectionReference courseCollection =
		firestore.collection(courseKey);

	/// Uploads students to the cloud. 
	/// 
	/// Puts all students in a batch and commits them all at once.
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

	/// Uploads a month of the calendar to the cloud. 
	/// 
	/// This collection is assumed to already contain a document for each month,
	/// so [fb.DocumentRefernce.update] is used instead of 
	/// [fb.DocumentRefernce.setData].
	static Future<void> uploadMonth(int month, List<Day> calendar) =>
		calendarCollection.document(month.toString()).updateData(
			fb.UpdateData.fromMap({
				"calendar": [
					for (final Day day in calendar)
						day.json
				]
			}
		)
	);

	/// Uploads all the courses to the cloud.
	/// 
	/// This function uses [fb.WriteBatch] to upload more efficiently. However, 
	/// each batch can only contain a maximum of 500 documents, but there are more
	/// courses than that. So this function splits it up into as many batches as 
	/// it needs to upload successfully.
	static Future<void> uploadCourses(List<Course> courses) async {
		final List<fb.WriteBatch> batches = [];
		int count = 0;
		for (final Course course in courses) {
			if (count % 500 == 0) {
				batches.add(firestore.batch());
			}
			batches [batches.length - 1].setData(
				courseCollection.document(course.id),
				fb.DocumentData.fromMap(course.json),
			);
			count++;
		}
	}
}