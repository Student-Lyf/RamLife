import "package:cloud_firestore/cloud_firestore.dart";

import "auth.dart";
import "firebase_core.dart";
import "service.dart";

export "package:cloud_firestore/cloud_firestore.dart";

/// Convenience methods on [CollectionReference].
extension CollectionHelpers on CollectionReference<Map> {
	/// Returns a [DocumentReference] by querying a field. 
	Future<DocumentReference> findDocument(String field, String value) async {
		final Query query = where(field, isEqualTo: value);
		final QuerySnapshot querySnapshot = await query.get();
		final QueryDocumentSnapshot snapshot = querySnapshot.docs.first;
		final DocumentReference document = snapshot.reference;
		return document;
	}

	/// Gets all the documents in a collection.
	Future<List<Map>> getAll() async => [
		for (final QueryDocumentSnapshot<Map> doc in (await get()).docs)
			doc.data()
	];
}

/// Convenience methods on [DocumentReference].
extension DocumentHelpers on DocumentReference<Map> {
	/// Gets data from a document, throwing if null.
	Future<Map> throwIfNull(String message) async {
		final Map? value = (await get()).data();
		if (value == null) {
			throw StateError(message);
		} else {
			return value;
		}
	} 
}

/// The Firestore database service.
/// 
/// This service does not provide any helper methods for data. That is reserved
/// for another service that will specify which data it is responsible for. 
/// This service just manages the connection to Firestore. 
/// 
/// This class provides the basic initialization behind Firestore, and 
/// doesn't expose any methods that will help retreive data. Any methods that 
/// are provided don't have an offline equivalent. 
class Firestore extends DatabaseService {
	/// The singleton instance of this service.
	static final FirebaseFirestore instance = FirebaseFirestore.instance;

	@override
	Future<void> init() async{
		await FirebaseCore.init();
		if(FirebaseCore.shouldUseEmulator){
			FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
		}
	}

	@override
	Future<void> signIn() => Auth.signIn();

	@override
	Future<void> signOut() => Auth.signOut();

	/// Submits feedback to the feedback collection.
	Future<void> sendFeedback(Map json) => instance.collection("feedback").doc()
		.set(Map<String, dynamic>.from(json));

	/// Listens to a month for changes in the calendar. 
	Stream<List<Map?>> getCalendarStream(int month) => instance
		.collection("calendar").doc(month.toString()).snapshots().map(
			(DocumentSnapshot<Map<String, dynamic>> snapshot) => [
				for (final dynamic entry in snapshot.data()! ["calendar"])
					if (entry == null) null
					else Map.from(entry)
				]
		);
}
