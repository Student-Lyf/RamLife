import "package:cloud_firestore/cloud_firestore.dart";

import "auth.dart";
import "firebase_core.dart";
import "service.dart";

/// Convenience methods on [CollectionReference].
extension CollectionHelpers on CollectionReference {
	/// Returns a [DocumentReference] by querying a field. 
	Future<DocumentReference> findDocument(String field, String value) async {
		final Query query = where(field, isEqualTo: value);
		final QuerySnapshot querySnapshot = await query.get();
		final QueryDocumentSnapshot snapshot = querySnapshot.docs.first;
		final DocumentReference document = snapshot.reference;
		return document;
	}
}

/// Convenience methods on [DocumentReference].
extension DocumentHelpers on DocumentReference {
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
/// Users of this service will still need to import cloud_firestore. That's 
/// because this class provides the basic initialization behind Firestore, and 
/// doesn't expose any methods that will help retreive data. 
class Firestore extends Service {
	/// The singleton instance of this service.
	static final FirebaseFirestore instance = FirebaseFirestore.instance;

	@override
	Future<void> init() => FirebaseCore.init();

	@override
	Future<void> signIn() => Auth.signIn();
}
