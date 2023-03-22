import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";

/// An exception thrown when no account has been selected. 
class NoAccountException implements Exception {}

// ignore: avoid_classes_with_only_static_members
/// An abstraction around FirebaseAuth.
/// 
/// This class handles all authentication operations via static methods. Do 
/// not create an instance of this class; it is not a Service. Instead, use 
/// it from within other services. 
class Auth {
	/// The [FirebaseAuth] service.
	static final FirebaseAuth auth = FirebaseAuth.instance;

	/// The [GoogleSignIn] service.
	static final GoogleSignIn google = GoogleSignIn(hostedDomain: "ramaz.org");

	/// The scope for calendar admins. 
	/// 
	/// This string should be found in the user's Firebase custom claims. 
	static const String calendarScope = "calendar";

	/// The scope for sports admins. 
	/// 
	/// This string should be found in the user's Firebase custom claims. 
	static const String sportsScope = "sports";

	/// The currently logged in user.
	/// 
	/// This getter returns a [User], which should not be used 
	/// outside this library. This method should only be called by 
	/// methods that provide higher level functionality, such as [isSignedIn].
	static User? get _currentUser => auth.currentUser;

	/// The user's email.
	/// 
	/// Since the database is case-sensitive, we standardize the lower case. 
	static String? get email => _currentUser?.email?.toLowerCase();

	/// The user's full name.
	static String? get name => _currentUser?.displayName;

	/// Determines whether the user is currently logged
	static bool get isSignedIn => _currentUser != null;

	/// Gets the user's custom claims. 
	/// 
	/// See the official [Firebase docs](https://firebase.google.com/docs/auth/admin/custom-claims). 
	static Future<Map<String, dynamic>?> get claims async => !isSignedIn ? null
		: (await _currentUser!.getIdTokenResult()).claims;

	/// Whether the user is an admin. 
	/// 
	/// This works by checking for an "isAdmin" flag in the user's custom [claims].
	static Future<bool> get isAdmin async {
		final Map? customClaims = await claims;
		return customClaims != null && (customClaims ["isAdmin"] ?? false);
	}

	/// The scopes of an admin. 
	/// 
	/// Returns null if the user is not an admin (ie, [isAdmin] returns false).
	static Future<List<String>?> get adminScopes async {
		final Iterable? customClaims = (await claims) ?["scopes"];
		return customClaims == null ? null : [
			for (final String scope in customClaims)
				scope.toString()
		];
	}

	/// Whether the user is an admin for the calendar. 
	static Future<bool> get isCalendarAdmin async => 
		(await adminScopes)?.contains(calendarScope) ?? false;

	/// Whether the user is an admin for sports games. 
	static Future<bool> get isSportsAdmin async => 
		(await adminScopes)?.contains(sportsScope) ?? false;		

	/// Signs out the currently logged in user.
	static Future<void> signOut() async {
		await google.signOut();
		await google.disconnect();
		await auth.signOut();
	}

	static Future<void> signInSilently() => google.signInSilently();

	/// Signs the user in using Google as a provider. 
	static Future<void> signIn() async {
		final GoogleSignInAccount? googleAccount = await google.signIn();
		if (googleAccount == null) {
			throw NoAccountException();
		}
		final GoogleSignInAuthentication googleAuth = 
			await googleAccount.authentication;

		final AuthCredential credential = GoogleAuthProvider.credential(
			accessToken: googleAuth.accessToken,
			idToken: googleAuth.idToken,
		);

		await auth.signInWithCredential(credential);
	}
}
