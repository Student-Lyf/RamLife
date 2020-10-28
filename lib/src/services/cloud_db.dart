import "package:cloud_firestore/cloud_firestore.dart";

import "auth.dart";
import "database.dart";
import "firebase_core.dart";

/// A wrapper around Cloud Firestore. 
class CloudDatabase extends Database {
	static final DateTime _now = DateTime.now();

	/// The [FirebaseFirestore service].
	static final FirebaseFirestore firestore = FirebaseFirestore.instance;

	/// The field in the reminders document that stores the reminders.
	static const String remindersKey = "reminders";

	/// The field in the calendar document that stores the calendar.
	static const String calendarKey = "calendar";

	/// The field in the sports document that stores the games. 
	static const String sportsKey = "games";

	/// The user data collection.
	/// 
	/// Note that even though this is named students, faculty are supported too.
	/// Each user has their own document to store their data. 
	/// 
	/// To access a document in this collection, use [userDocument]. 
	static final CollectionReference userCollection = 
		firestore.collection("students");

	/// The admin profile collection.
	/// 
	/// Each admin has their own document to store their data. Note that the 
	/// documents themselves do not grant admin privileges, since admins can modify
	/// their own document. Rather, the scopes of their privileges are stored in 
	/// FirebaseAuth custom claims. See [Auth.adminScopes]. 
	/// 
	/// To access a document in this collection, use [adminDocument].
	static final CollectionReference adminCollection = 
		firestore.collection("admin");

	/// The course data collection.
	/// 
	/// Sections, not courses, are stored in the database. Each section has its 
	/// own document with the data of that section. 
	/// 
	/// Do not access documents in this collection directly. 
	/// Use either [getSections] or [getSection]. 
	static final CollectionReference sectionCollection =
		firestore.collection("classes");

	/// The calendar collection. 
	/// 
	/// The calendar collection consists of 12 documents, one for each month. 
	/// Each document has its month's data in the [calendarKey] field. 
	/// 
	/// Do not access documents in this collection directly.
	/// Instead, use [calendar] or [getCalendarMonth]. 
	static final CollectionReference calendarCollection =
		firestore.collection("calendar");

	/// The feedback collection.
	/// 
	/// Users can only create new documents here, not edit existing ones. 
	/// 
	/// Do not access documents in this collection.
	/// Instead, create new ones. 
	static final CollectionReference feedbackCollection =
		firestore.collection("feedback");

	/// The reminders collection. 
	/// 
	/// Each user has their own document here that holds just their reminders. 
	/// The decision to separate reminders from the rest of the user data was 
	/// made to minimize the amount of processing time, since the student document
	/// contains other irrelevant data. 
	/// 
	/// To access a document in this collection, use [remindersDocument].
	static final CollectionReference remindersCollection = 
		firestore.collection("reminders");

	/// The sports collection. 
	/// 
	/// Each academic year has its own document, with all the games for that year 
	/// in a list. This structure is still up for redesign, but seems to hold up.
	/// 
	/// To access a document in this collection, use [sportsDocument].
	static final CollectionReference sportsCollection =
		firestore.collection("sports");

	/// The document for this user's data. 
	/// 
	/// The collection is indexed by email. 
	DocumentReference get userDocument => 
		userCollection.doc(Auth.email);

	/// The document for this user's reminders. 
	/// 
	/// The collection is indexed by email. 
	DocumentReference get remindersDocument => 
		remindersCollection.doc(Auth.email);

	/// The document for this user's admin profile. 
	/// 
	/// The collection is indexed by email.
	DocumentReference get adminDocument => 
		adminCollection.doc(Auth.email);

	/// The document for this academic year's sports games.
	///  
	/// The collection is indexed by `"$firstYear-$secondYear"` (eg, 2020-2021).  
	DocumentReference get sportsDocument => sportsCollection.doc(_now.month > 7 
		? "${_now.year}-${_now.year + 1}"
		: "${_now.year - 1}-${_now.year}"
	);

	// Service methods

	@override
	Future<void> init() => FirebaseCore.init();

	/// Signs the user in.
	/// 
	/// If the user does not have a reminders document, this function creates it.
	@override
	Future<void> signIn() async {
		await Auth.signIn();
		final DocumentSnapshot remindersSnapshot = await remindersDocument.get();
		if (!remindersSnapshot.exists) {
			await remindersDocument.set({remindersKey: []});
		}
	}

	// Database methods. 

	@override
	bool get isSignedIn => Auth.isSignedIn;

	@override
	Future<void> signOut() => Auth.signOut();

	@override
	Future<Map<String, dynamic>> get user async {
		final DocumentSnapshot snapshot = await userDocument.get();
		if (!snapshot.exists) {
			throw StateError("User ${Auth.email} does not exist in the database");
		} else {
			return snapshot.data();
		}
	}

	/// No-op -- The user cannot edit their own profile. 
	/// 
	/// User profiles can only be modified by the admin SDK. 
	/// Admin profiles may be modified. See [setAdmin]. 
	@override
	Future<void> setUser(Map<String, dynamic> json) async {}

	@override
	Future<Map<String, dynamic>> getSection(String id) async => 
		(await sectionCollection.doc(id).get()).data();

	/// No-op -- The user cannot edit the courses list. 
	/// 
	/// The courses list can only be modified by the admin SDK. 
	@override
	Future<void> setSections(Map<String, Map<String, dynamic>> json) async {}

	@override
	Future<Map<String, dynamic>> getCalendarMonth(int month) async {
		final DocumentReference document = calendarCollection.doc(month.toString());
		final DocumentSnapshot snapshot = await document.get();
		final Map<String, dynamic> data = snapshot.data();
		return data;
	}

	@override 
	Future<void> setCalendar(int month, Map<String, dynamic> json) => 
		calendarCollection.doc(month.toString()).set(json);

	@override
	Future<List<Map<String, dynamic>>> get reminders async {
		final DocumentSnapshot snapshot = await remindersDocument.get();
		final Map<String, dynamic> data = snapshot.data();
		return [
			for (final dynamic json in data [remindersKey])
				Map<String, dynamic>.from(json)
		];
	}

	@override
	Future<void> setReminders(List<Map<String, dynamic>> json) => 
		remindersDocument.set({remindersKey: json});

	@override
	Future<Map<String, dynamic>> get admin async => 
		(await adminDocument.get()).data();

	@override
	Future<void> setAdmin(Map<String, dynamic> json) => adminDocument.set(json);

	@override
	Future<List<Map<String, dynamic>>> get sports async {
		final DocumentSnapshot snapshot = await sportsDocument.get();
		final Map<String, dynamic> data = snapshot.data();
		return [
			for (final dynamic json in data [sportsKey])
				Map<String, dynamic>.from(json)
		];
	}

	@override
	Future<void> setSports(List<Map<String, dynamic>> json) => 
		sportsDocument.set({sportsKey: json});

	/// Submits feedback. 
	Future<void> sendFeedback(
		Map<String, dynamic> json
	) => feedbackCollection.doc().set(json);

	/// Listens to a month for changes in the calendar. 
	Stream<List<Map<String, dynamic>>> getCalendarStream(int month) => 
		calendarCollection.doc(month.toString()).snapshots().map(
			(DocumentSnapshot snapshot) => [
				for (final dynamic entry in snapshot.data() ["calendar"])
					Map<String, dynamic>.from(entry)
				]
		);
}
