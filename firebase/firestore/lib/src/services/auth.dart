import "package:firebase_admin_interop/firebase_admin_interop.dart" as fb;

import "package:node_interop/util.dart" show dartify;

import "firebase.dart";

/// Holds the names for the admin scopes.
class Scopes {
	/// The scope name for calendar admins.
	static const String calendar = "calendar";

	/// The scope name for publication admins.
	static const String publications = "publications";

	/// The scope name for sports admins.
	static const String sports = "sports";

	/// A list of all acceptable scopes. 
	/// 
	/// These scopes are the only ones recognized by the app. Since the data is 
	/// pulled from a file, this safeguards against typos.
	static const Set<String> scopes = {calendar, publications, sports};
}

/// A wrapper around FirebaseAuth.
class Auth {
	/// The FirebaseAuth instance behind this class.
	static final fb.Auth auth = app.auth();

	/// Grants a user admin privileges.
	/// 
	/// Available scopes are held as constants in [Scopes].
	static Future<void> setScopes(String email, List<String> scopes) async => 
		auth.setCustomUserClaims(
			(await getUser(email)).uid, 
			{"isAdmin": scopes.isNotEmpty, "scopes": scopes}
		);

	/// Creates a user. 
	static Future<void> createUser(String email) => auth
		.createUser(fb.CreateUserRequest(email: email));

	/// Gets the user with the given email, or creates one
	static Future<fb.UserRecord> getUser(String email) async {
		try {
			return await auth.getUserByEmail(email);
		} catch (error) {  // ignore: avoid_catches_without_on_clauses
			// package:firebase_admin_interop is not so good with error types
			if (error.code == "auth/user-not-found") {
				await createUser(email);
				return getUser(email);
			} else {
				rethrow;	
			}
		}
	}

	/// Gets the custom claims for a user. 
	static Future<Map<String, dynamic>> getClaims(String email) async {
		final fb.UserRecord user = await getUser(email);
		return dartify(user.customClaims);
	}
}
