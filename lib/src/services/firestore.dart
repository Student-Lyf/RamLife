import "package:cloud_firestore/cloud_firestore.dart" as fb;

import "auth.dart";

// ignore: avoid_classes_with_only_static_members
/// An abstraction wrapper around Cloud Firestore. 
/// 
/// This class only handles raw data transfer to and from Cloud Firestore.
/// Do not attempt to use dataclasses here, as that will create a dependency
/// between this library and the data library. 
class Firestore {
	static final DateTime _now = DateTime.now();

	/// The name for the student schedule collection.
	static const String students = "students";

	/// The name for the admins collection. 
	static const String admins = "admin";

	/// The name of the classes collection.
	static const String classes = "classes";

	/// The name of the calendar collection.
	static const String calendarKey = "calendar";
	
	/// The name of the feedback collection.
	static const String feedback = "feedback";

	/// The name of the reminders collection.
	static const String remindersKey = "reminders";

	/// The name of the sports collection.
	static const String sportsKey = "sports";

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
		_firestore.collection(calendarKey);
	
	static final fb.CollectionReference _reminders = 
		_firestore.collection (remindersKey);

	static final fb.CollectionReference _sports = 
		_firestore.collection(sportsKey);

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
		Set<String> ids		
	) async {
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

	/// Downloads the calendar for a given month. 
	static Future<List<List<Map<String, dynamic>>>> getCalendar(
		{bool download = false}
	) async => [
		for (int month = 1; month < 13; month++) <Map<String, dynamic>>[
			for (final entry in (await _calendar.document(month.toString()).get(
				source: download ? fb.Source.server : fb.Source.serverAndCache,
			)).data ["calendar"])
				Map<String, dynamic>.from(entry)
		]
	];

	/// Uploads the given month to the Firestore calendar collection. 
	static Future<void> saveCalendar(int month, List<Map<String, dynamic>> json) =>
		_calendar.document(month.toString()).setData({"calendar": json});

	/// Listens to a month for changes in the calendar. 
	static Stream<List<Map<String, dynamic>>> getCalendarStream(int month) => 
		_calendar.document(month.toString()).snapshots().map(
			(fb.DocumentSnapshot snapshot) => [
				for (final dynamic entry in snapshot.data ["calendar"])
					Map<String, dynamic>.from(entry)
				]
		);

	/// Downloads the reminders for the user. 
	/// 
	/// At least for now, these are stored in a spearate collection than
	/// the student profile data. This choice was made since reminders are 
	/// updated frequently and this saves the system from processing the
	/// student's schedule every time this happens. 
	static Future<List<Map<String, dynamic>>> get reminders async {
		// If the user never made a reminder yet, the document will not exist. 
		// So the map of data needs to be fetched first, and if it's null,
		// return null. If the document does exist, check the `reminders` field. 
		// 
		// Get the document as a json. This may be null. 
		final Map<String, dynamic> json = (await _reminders.document(
			await Auth.email
		).get())?.data;

		// If the document doesn't exist, `json` will be null.
		// If it is, set this to null. 
		// Otherwise, set it to the `reminders` field. 
		final List listOfReminders = json == null 
			? [] : (json ["reminders"] ?? []);
		return <Map<String, dynamic>>[
			for (final entry in listOfReminders)
				Map<String, dynamic>.from(entry)
		];
	} 

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
		List<Map<String, dynamic>> remindersList, 
	) async => _reminders
		.document(await Auth.email)
		.setData({"reminders": remindersList});

	/// Retrieves the admin data from the cloud.
	/// 
	/// Admins have their own collection. However, this collection is not what 
	/// provides users with administrative privileges. That is handled by Firebase
	/// Authentication custom tokens. The document here simply provides helpful
	/// data for the user, such as their custom-made specials. 
	static Future<Map<String, dynamic>> get admin async => 
		(await _admin.document(await Auth.email).get()).data;

	/// Saves the admin profile to the cloud. 
	static Future<void> saveAdmin (Map<String, dynamic> data) async => 
		_admin.document(await Auth.email).setData(data);

	/// The document name for this school year's sports games.
	///  
	/// Each document is titled `"$firstYear-$secondYear" and has a 
	/// `games` field for a list of JSON entries. 
	static String get sportsDocument => _now.month > 7 
		? "${_now.year}-${_now.year + 1}"
		: "${_now.year - 1}-${_now.year}";

	/// Downloads the sports data from the database. 
	/// 
	/// The sports games are split into documents by school year. Each document
	/// has a `games` field for a list of JSON entries. 
	static Future<List<Map<String, dynamic>>> get sports async => [
		for (final dynamic entry in (
			await _sports.document(sportsDocument).get()
		).data ["games"]) 
			Map<String, dynamic>.from(entry)
	];

	/// Saves the list of sports games to the database. 
	static Future<void> saveGames(List<Map<String, dynamic>> games) async => 
		_sports.document(sportsDocument).setData({
			"games": games,
		});
}
