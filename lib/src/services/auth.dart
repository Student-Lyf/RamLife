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
	static Future<void> signInWithGoogle(void Function() ifInvalid) async {
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
