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
			(await auth.getUserByEmail(email)).uid, 
			{"isAdmin": scopes.isNotEmpty, "scopes": scopes}
		);

	static Future<Map<String, dynamic>> getClaims(String email) async => dartify(
		(await auth.getUserByEmail(email)).customClaims
	);
}
