import 'package:firebase_auth/firebase_auth.dart';
import "package:google_sign_in/google_sign_in.dart";
import "dart:async" show Future;

final FirebaseAuth firebase = FirebaseAuth.instance;
final GoogleSignIn google = GoogleSignIn();

Future<FirebaseUser> currentUser() async => await firebase.currentUser();

Future<bool> ready() async => await currentUser() != null;

Future<void> signOut() async {
	await firebase.signOut();
	await google.signOut();
}

Future<bool> supportsGoogle() async => !(await currentUser())
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

Future<void> signInWithEmail(String email) async {
	await firebase.sendSignInWithEmailLink(
		email: email, 
		url: "https://ramaz.page.link/email-login",
		// url: "https://www.ramaz.org/page.cfm?p=114",
		handleCodeInApp: true, 
		iOSBundleID: "com.ramaz.student-life", 
		androidPackageName: "com.ramaz.student_life",
		androidInstallIfNotAvailable: false, 
		androidMinimumVersion: "21"
	);
}

Future<bool> isSignInLink(String link) async => 
	await firebase.isSignInWithEmailLink(link);