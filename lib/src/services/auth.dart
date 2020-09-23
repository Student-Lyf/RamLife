import "package:firebase_auth/firebase_auth.dart";
import "package:google_sign_in/google_sign_in.dart";

// ignore: avoid_classes_with_only_static_members
/// An abstraction around FirebaseAuth.
/// 
/// This class handles all authentication operations via static methods.
/// There is no need to create an instance of this class.
class Auth {
	/// The [FirebaseAuth] service.
	static final FirebaseAuth auth = FirebaseAuth.instance;

	/// The [GoogleSignIn] service.
	static final GoogleSignIn google = GoogleSignIn(hostedDomain: "ramaz.org");

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
	/// This getter returns a [User], which should not be used 
	/// outside this library. This method should only be called by 
	/// methods that provide higher level functionality, such as [isReady].
	static User get currentUser => auth.currentUser;

	/// The user's email.
	static String get email => currentUser?.email;

	/// The user's full name.
	static String get name => currentUser?.displayName;

	/// Determines whether the user is currently logged
	static bool get isReady => currentUser != null;

	/// Whether the user is an admin or not. 
	static Future<Map> get claims async => (
		await currentUser.getIdTokenResult()
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
		await google.signOut();
		await auth.signOut();
	}

	/// Signs the user in using Google as a provider. 
	static Future<void> signIn() async {
		final GoogleSignInAccount googleAccount = await google.signIn();
		if (googleAccount == null) {
			return;
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
