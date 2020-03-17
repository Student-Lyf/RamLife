import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";

// ignore: avoid_classes_with_only_static_members
/// An abstraction around FirebaseAuth.
/// 
/// This class handles all authentication operations via static methods.
/// There is no need to create an instance of this class.
class Auth {
	static final FirebaseAuth _firebase = FirebaseAuth.instance;
	static final GoogleSignIn _google = GoogleSignIn();

	/// The scope for the calendar.
	/// 
	/// This string should be found in the users Firebase custom claims. 
	static const String calendarScope = "calendar";

	/// The scope for sports games. 
	/// 
	/// This string should be found in the users Firebase custom claims. 
	static const String sportsScope = "sports";

	/// The currently logged in user.
	/// 
	/// This getter returns a [FirebaseUser], which should not be used 
	/// outside this library. This method should only be called by 
	/// methods that provide higher level functionality, such as [ready].
	static Future<FirebaseUser> get currentUser => _firebase.currentUser();

	/// The user's email.
	static Future<String> get email async => (await currentUser)?.email;

	/// The user's full name.
	static Future<String> get name async => (await currentUser)?.displayName;

	/// Determines whether the user is currently logged
	static Future<bool> get ready async => await currentUser != null;

	/// Whether the user is an admin or not. 
	static Future<Map> get claims async => (
		await (await currentUser).getIdToken()
	).claims;

	/// Whether the user is an admin. 
	static Future<bool> get isAdmin async => (await claims) ["isAdmin"] ?? false;

	/// The scopes of an admin. 
	/// 
	/// No null-checks are necessary here, because the `scopes` field should be 
	/// present if the user is an admin, and this property will not be accessed 
	/// unless [isAdmin] returns true. 
	static Future<List<String>> get adminScopes async => [
		for (final scope in (await claims) ["scopes"])
			scope.toString()
	];

	/// Whether the user is an admin for the calendar. 
	static Future<bool> get isCalendarAdmin async => 
		(await isAdmin) && (await adminScopes).contains(calendarScope);

	/// Whether the user is an admin for sports games. 
	static Future<bool> get isSportsAdmin async => 
		(await isAdmin) && (await adminScopes).contains(sportsScope);		

	/// Signs out the currently logged in user.
	static Future<void> signOut() async {
		await _firebase.signOut();
		await _google.signOut();
	}

	/// Determines whether the provided email is a valid Ramaz account
	/// 
	/// This does no server side validation, only checking if it ends in 
	/// "@ramaz.org".
	static bool isValidGoogleAccount(GoogleSignInAccount account) => account
		.email.endsWith("@ramaz.org");

	/// Signs in the user with Google as the provider. 
	static Future<void> signInWithGoogle() async {
		final GoogleSignInAccount account = await _google.signIn();
		if (account == null) {
			return;
		}
		final GoogleSignInAuthentication _auth = await account.authentication;
		final AuthCredential credential = GoogleAuthProvider.getCredential (
			accessToken: _auth.accessToken,
			idToken: _auth.idToken
		);
		await _firebase.signInWithCredential(credential);
	}
}
