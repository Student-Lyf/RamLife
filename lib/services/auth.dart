import 'package:firebase_auth/firebase_auth.dart';
import "package:google_sign_in/google_sign_in.dart";
import "dart:async" show Future;

final FirebaseAuth firebase = FirebaseAuth.instance;
final GoogleSignIn google = GoogleSignIn();

// Can't just do username + password, so use Ramaz email
Future<void> signIn(String username, String password) async => await firebase
	.signInWithEmailAndPassword(
		email: username + "@ramaz.org",
		password: password
	);

Future<FirebaseUser> currentUser() async => await firebase.currentUser();
Future<bool> ready() async => await currentUser() != null;
Future<void> signOut() async {
	await firebase.signOut();
	await google.signOut();
}

Future<bool> needsGoogleSupport() async => !(await currentUser())
	.providerData.any (
		(UserInfo provider) => provider.providerId == "google.com"
	);

bool isValidGoogleAccount(GoogleSignInAccount account) => account
	.email.endsWith("@ramaz.org");

Future<GoogleSignInAccount> signInWithGoogle(
	void Function() ifInvalid,
	{bool link = false}
) async {
	final GoogleSignInAccount account = await google.signIn();
	if (account == null) return null;
	if (!isValidGoogleAccount(account)) {
		ifInvalid();
		await google.signOut();  // Prompt again 
		return null;
	}
	final GoogleSignInAuthentication _auth = await account.authentication;
	AuthCredential credential = GoogleAuthProvider.getCredential (
		accessToken: _auth.accessToken,
		idToken: _auth.idToken
	);
	if (link) await firebase.linkWithCredential(credential);
	else await firebase.signInWithCredential(credential);
	return account;
}

Future<List<String>> getSignInMethods(String username) async =>
	await firebase.fetchSignInMethodsForEmail(email: username + "@ramaz.org");
