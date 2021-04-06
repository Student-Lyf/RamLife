import "package:cloud_firestore/cloud_firestore.dart";

import "auth.dart";
import "database.dart";
import "firebase_core.dart";

/// Convenience methods on [CollectionReference].
extension DocumentFinder on CollectionReference {
	/// Returns a [DocumentReference] by querying a field. 
	Future<DocumentReference> findDocument(String field, String value) async {
		final Query query = where(field, isEqualTo: value);
		final QueryDocumentSnapshot snapshot = (await query.get()).docs.first;
		final DocumentReference document = snapshot.reference;
		return document;
	}
}

/// Convenience methods on [DocumentReference].
extension NonNullData on DocumentReference {
	/// Gets data from a document, throwing if null.
	Future<Map<String, dynamic>> throwIfNull(String message) async {
		final Map<String, dynamic>? value = (await get()).data();
		if (value == null) {
			throw StateError(message);
		} else {
			return value;
		}
	} 
}

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

	/// The reminders collection. 
	/// 
	/// Each user document has a sub-collection that has their a document for each 
	/// reminder.
	CollectionReference get remindersCollection =>
		userDocument.collection("reminders");

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
	}

	// Database methods. 

	@override
	bool get isSignedIn => Auth.isSignedIn;

	@override
	Future<void> signOut() => Auth.signOut();

	@override
	Future<Map<String, dynamic>> get user => 
		userDocument.throwIfNull("User ${Auth.email} does not exist in the database");

	/// No-op -- The user cannot edit their own profile. 
	/// 
	/// User profiles can only be modified by the admin SDK. 
	/// Admin profiles may be modified. See [setAdmin]. 
	@override
	Future<void> setUser(Map<String, dynamic> json) async {}

	@override
	Future<Map<String, dynamic>> getSection(String id) =>
		sectionCollection.doc(id).throwIfNull("Cannot find section: $id");

	/// No-op -- The user cannot edit the courses list. 
	/// 
	/// The courses list can only be modified by the admin SDK. 
	@override
	Future<void> setSections(Map<String, Map<String, dynamic>> json) async {}

	@override
	Future<Map<String, dynamic>> getCalendarMonth(int month) async {
		final DocumentReference document = calendarCollection.doc(month.toString());
		return document.throwIfNull("No entry in calendar for $month");
	}

	@override 
	Future<void> setCalendar(int month, Map<String, dynamic> json) => 
		calendarCollection.doc(month.toString()).set(json);

	@override
	Future<List<Map<String, dynamic>>> get reminders async {
		final QuerySnapshot snapshot = 
			await remindersCollection.orderBy(FieldPath.documentId).get();
		final List<QueryDocumentSnapshot> documents = snapshot.docs;
		return [
			for (final QueryDocumentSnapshot document in documents)
				// QueryDocumentSnapshot.data() is never null. 
				// I opened a PR to make the type non-nullable: 
				// https://github.com/FirebaseExtended/flutterfire/pull/5476
				document.data()!
		];
	}

	@override
	Future<void> updateReminder(String? oldHash, Map<String, dynamic> json) async {
		if (oldHash == null) {
			await remindersCollection.add(json);
		} else {
			final DocumentReference document = await remindersCollection
				.findDocument("hash", oldHash);
			await document.set(json);
		}
	}

	@override
	Future<void> deleteReminder(String oldHash) async =>
		(await remindersCollection.findDocument("hash", oldHash)).delete();

	@override
	Future<Map<String, dynamic>> get admin => 
		adminDocument.throwIfNull("User is not admin");

	@override
	Future<void> setAdmin(Map<String, dynamic> json) => adminDocument.set(json);

	@override
	Future<List<Map<String, dynamic>>> get sports async {
		final Map<String, dynamic> data = await sportsDocument
			.throwIfNull("No sports data found");
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
	Stream<List<Map<String, dynamic>?>> getCalendarStream(int month) => 
		calendarCollection.doc(month.toString()).snapshots().map(
			(DocumentSnapshot snapshot) => [
				for (final dynamic entry in snapshot.data()! ["calendar"])
					if (entry == null) null
					else Map<String, dynamic>.from(entry)
				]
		);
}
