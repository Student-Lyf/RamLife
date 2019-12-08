import "package:cloud_firestore/cloud_firestore.dart" as fb;

import "package:ramaz/data.dart";

import "auth.dart";

// ignore: avoid_classes_with_only_static_members
/// An abstraction wrapper around Cloud Firestore. 
/// 
/// This class only handles raw data transfer to and from Cloud Firestore.
/// Do not attempt to use dataclasses here, as that will create a dependency
/// between this library and the data library. 
class Firestore {
	/// The name for the student schedule collection
	static const String students = "students";

	static const String admins = "admin";

	/// The name of the classes collection
	static const String classes = "classes";

	/// The name of the calendar collection
	static const String calendar = "calendar";
	
	/// The name of the feedback collection
	static const String feedback = "feedback";

	/// The name of the reminders collection
	static const String remindersKey = "reminders";

	static final fb.Firestore _firestore = fb.Firestore.instance;

	static final fb.CollectionReference _students = 
		_firestore.collection(students);

	static final fb.CollectionReference _admin = 
		_firestore.collection(admins);
	
	static final fb.CollectionReference _classes = 
		_firestore.collection (classes);
	
	static final fb.CollectionReference _feedback = 
		_firestore.collection (feedback);
	
	static final fb.CollectionReference _calendar = 
		_firestore.collection(calendar);
	
	static final fb.CollectionReference _reminders = 
		_firestore.collection (remindersKey);

	/// Downloads the student's document in the student collection.
	static Future<Map<String, dynamic>> get student async => 
		(await _students.document(await Auth.email).get()).data;

	/// Downloads the relevant document in the `classes` collection.
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
	static Future<Map<String, Map<String, dynamic>>> getClasses(
		Student student
	) async {
		final Set<String> ids = {};
		for (final List<PeriodData> schedule in student.schedule.values) {
			for (final PeriodData period in schedule) {
				if (
					period == null || period.id == null
				) {
					continue;  // skip free periods
				}
				ids.add(period.id);
			}
		}
		ids.add (student.homeroom);
		final Map<String, Map<String, dynamic>> result = {};
		for (final String id in ids) {
			result [id] = await getClass(id);
		}
		return result;
	}

	/// Submits feedback. 
	/// 
	/// The feedback collection is write-only, and can only be accessed by admins.
	static Future<void> sendFeedback(
		Map<String, dynamic> json
	) => _feedback.document().setData(json);

	/// Downloads the calendar for the current month. 
	static Future<Map<String, dynamic>> getMonth(
		{bool download = false}
	) async => (
		await _calendar.document(DateTime.now().month.toString()).get(
			source: download ? fb.Source.server : fb.Source.serverAndCache,
		)
	).data;

	static Future<void> saveCalendar(int mont, Map<String, dynamic> json) => 
		_calendar.document(month.toString()).setData(json);

	static Stream<fb.DocumentSnapshot> getCalendar(int month) => 
		_calendar.document(month.toString()).snapshots();

	/// Downloads the reminders for the user. 
	/// 
	/// At least for now, these are stored in a spearate collection than
	/// the student profile data. This choice was made since reminders are 
	/// updated frequently and this saves the system from processing the
	/// student's schedule every time this happens. 
	static Future<Map<String, dynamic>> get reminders async => 
		(await _reminders.document(await Auth.email).get()).data;

	/// Uploads the user's reminders to the database. 
	/// 
	/// This function saves the reminders along with a record of the reminders
	/// that were already read. Those reminders will be deleted once they are
	/// irrelevant.
	/// 
	/// This should be re-written to only accept a list of JSON elements, as 
	/// this creates a dependency between this library and the data library.
	/// This should also probably not persist the read reminders in the database 
	/// (ie, keep them local).
	static Future<void> saveReminders(
		List<Reminder> remindersList, 
		List<int> readReminders
	) async => _reminders
		.document(await Auth.email)
		.setData({
			"reminders": [
				for (final Reminder reminder in remindersList)
					reminder.toJson()
			],
			"read": readReminders
		});

	static Future<Map<String, dynamic>> get admin async => 
		(await _admin.document(await Auth.email).get()).data;

	static Future<void> saveAdmin (Map<String, dynamic> data) async => 
		_admin.document(await Auth.email).setData(data);
}
