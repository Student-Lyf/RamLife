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

	/// The name of the feedback collection.
	static const String feedbackKey = "feedback";

	/// The name of the reminders collection.
	static const String remindersKey = "reminders";

	static const String adminsKey = "admin";

	/// The students collection.
	static final fb.CollectionReference studentsCollection = 
		firestore.collection(studentsKey);

	/// The calendar collection.
	static final fb.CollectionReference calendarCollection = 
		firestore.collection(calendarKey);

	/// The course collection.
	static final fb.CollectionReference courseCollection =
		firestore.collection(courseKey);

	/// The feedback collection.
	static final fb.CollectionReference feedbackCollection =
		firestore.collection(feedbackKey);

	/// The reminders collection.
	static final fb.CollectionReference remindersCollection =
		firestore.collection(remindersKey);

	static final fb.CollectionReference adminsCollection = 
		firestore.collection(adminsKey);

	/// Deletes reminders froma given user that fit a predicate function.
	/// 
	/// If [transaction] is null, one will be created and passed to this function.
	static Future<List<Map<String, dynamic>>> deleteRemindersFromUser(
		String email,
		bool Function(Map<String, dynamic>) predicate,
		[fb.Transaction transaction]
	) async {
		if (transaction == null) {
			return firestore.runTransaction(
				(fb.Transaction transaction) => 
					deleteRemindersFromUser(email, predicate, transaction)
			);
		}

		final fb.DocumentReference document = remindersCollection.document(email);
		final fb.DocumentSnapshot snapshot = await transaction.get(document);

		final Map<String, dynamic> data = snapshot.data.toMap();
		final List<Map<String, dynamic>> reminders = [
			for(final reminder in data ["reminders"])
				Map<String, dynamic>.from(reminder)
		];
		final List<Map<String, dynamic>> filteredReminders = [
			for(final Map<String, dynamic> reminder in reminders)
				if (!predicate(reminder))
					reminder
		];
		transaction.update(
			document,
			fb.UpdateData.fromMap({"reminders": filteredReminders})
		);
		return filteredReminders;
	}

	/// Gets all the feedback sent from the app.
	/// 
	/// This data is stored in [feedbackCollection]. See [Feedback.fromJson] 
	/// for the format of these documents.
	static Future<List<Feedback>> getFeedback() async => [
		for (
			final fb.DocumentSnapshot document in 
			(await feedbackCollection.get()).documents
		)
			Feedback.fromJson(document.data.toMap())
	];

	/// Uploads users to the cloud. 
	/// 
	/// Puts all users in a batch and commits them all at once.
	static Future<void> uploadUsers(List<User> users) {
		final fb.WriteBatch batch = firestore.batch();
		for (final User user in users) {
			batch.setData(
				studentsCollection.document(user.email), 
				fb.DocumentData.fromMap(user.json)
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
				"month": month,
				"calendar": [
					for (final Day day in calendar)
						day?.json
				], 
			}
		)
	);

	/// Uploads all the sections to the cloud.
	/// 
	/// This function uses [fb.WriteBatch] to upload more efficiently. However, 
	/// each batch can only contain a maximum of 500 documents, but there are more
	/// sections than that. So this function splits it up into as many batches as 
	/// it needs to upload successfully.
	static Future<void> uploadSections(List<Section> sections) async {
		final List<fb.WriteBatch> batches = [];
		int count = 0;
		for (final Section section in sections) {
			if (count % 500 == 0) {
				batches.add(firestore.batch());
			}
			batches [batches.length - 1].setData(
				courseCollection.document(section.id),
				fb.DocumentData.fromMap(section.json),
			);
			count++;
		}
		for (final fb.WriteBatch batch in batches) {
			await batch.commit();
		}
	}

	static Future<List<Map<String, dynamic>>> getMonth(int month) async {
		final fb.DocumentReference document = 
			calendarCollection.document(month.toString());
		final fb.DocumentSnapshot snapshot = await document.get();
		final Map<String, dynamic> data = snapshot.data.toMap();
		final List<Map<String, dynamic>> calendar = [
			for (final dynamic json in data ["calendar"])	
				Map<String, dynamic>.from(json)
		];
		return calendar;
	} 

	static Future<void> uploadAdmin(String email) async => adminsCollection
		.document(email)
		.setData(
			fb.DocumentData.fromMap({"email": email}),
			fb.SetOptions(merge: true),
		);
}
