import 'package:firebase_auth/firebase_auth.dart';
import "package:google_sign_in/google_sign_in.dart";
import "dart:async" show Future;

class Auth {
	static final FirebaseAuth _firebase = FirebaseAuth.instance;
	static final GoogleSignIn google = GoogleSignIn();

	static Future<FirebaseUser> currentUser() async => await _firebase.currentUser();

	static Future<String> getEmail() async {
		final FirebaseUser user = await currentUser();
		return user == null ? null : user.email;
	}

	static Future<bool> ready() async => await currentUser() != null;

	static Future<void> signOut() async {
		await _firebase.signOut();
		await google.signOut();
	}

	static Future<bool> supportsGoogle() async => (await currentUser())
		.providerData.any (
			(UserInfo provider) => provider.providerId == "google.com"
		);

	static bool isValidGoogleAccount(GoogleSignInAccount account) => account
		.email.endsWith("@ramaz.org");

	static Future<GoogleSignInAccount> signInWithGoogle(
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
		if (link) await _firebase.linkWithCredential(credential);
		else await _firebase.signInWithCredential(credential);
		return account;
	}

	static Future<void> addGoogleSupport({
		void Function() callback, Future<void> Function() onSuccess
	}) async {
		final account = await signInWithGoogle(callback);
		if (account == null) return;
		await onSuccess();
	}
}