import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseUser;
import "dart:async" show Future;

final FirebaseAuth auth = FirebaseAuth.instance;

// Can't just do username + password, so use Ramaz email
Future<void> signin(String username, String password) async => await auth
	.signInWithEmailAndPassword(
		email: username + "@ramaz.org",
		password: password
	);

Future<FirebaseUser> currentUser() async => await auth.currentUser();
Future<void> signOut() async => await auth.signOut();
