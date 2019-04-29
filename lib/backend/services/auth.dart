import 'package:firebase_auth/firebase_auth.dart';
import "package:google_sign_in/google_sign_in.dart";
import "dart:async" show Future;

final FirebaseAuth auth = FirebaseAuth.instance;

// Can't just do username + password, so use Ramaz email
Future<void> signIn(String username, String password) async => await auth
	.signInWithEmailAndPassword(
		email: username + "@ramaz.org",
		password: password
	);

Future<FirebaseUser> currentUser() async => await auth.currentUser();
Future<void> signOut() async => await auth.signOut();

Future<void> signInWithGoogle(GoogleSignInAccount account) async {
	final GoogleSignInAuthentication _auth = await account.authentication;
	AuthCredential credential = GoogleAuthProvider.getCredential (
		accessToken: _auth.accessToken,
		idToken: _auth.idToken
	);
	await auth.signInWithCredential(credential);
}