import 'package:firebase_auth/firebase_auth.dart';
import "package:google_sign_in/google_sign_in.dart";

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
	static Future<FirebaseUser> currentUser() async => await _firebase.currentUser();

	/// Returns the email of the currently logged in user.
	static Future<String> getEmail() async {
		final FirebaseUser user = await currentUser();
		return user == null ? null : user.email;
	}

	/// Determines whether the user is currently logged
	static Future<bool> ready() async => await currentUser() != null;

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
	static Future<void> signInWithGoogle(
		void Function() ifInvalid,
	) async {
		final GoogleSignInAccount account = await _google.signIn();
		if (account == null) return;
		if (!isValidGoogleAccount(account)) {
			ifInvalid();
			await _google.signOut();  // Prompt again 
			return;
		}
		final GoogleSignInAuthentication _auth = await account.authentication;
		AuthCredential credential = GoogleAuthProvider.getCredential (
			accessToken: _auth.accessToken,
			idToken: _auth.idToken
		);
		await _firebase.signInWithCredential(credential);
		return;
	}
}
