import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, AuthCredential;
import "package:flutter/services.dart";

// signInWithCredential(AuthCredential)

final FirebaseAuth auth = FirebaseAuth.instance;


// abstract class Temp {
// 	Temp(this._provider);
// 	final int _provider;
// }


// class Credentials {
// 	final int temp = 0;
// 	Credentials(String username, String password)
// 		: super(0);
// 		 // : super (
// 			 	// "Ramaz",
// 			 	// {
// 			 	// 	"username": username,
// 			 	// 	"password": password
// 			 	// }
// 		 	// );
// 		 	// _provider = "Ramaz";
// 	// final String _provider = "Ramaz";
// 	// final Map<String, String> _data;
// }

void signin() async {
	// FirebaseUser user = await auth.signInWithCustomToken(token: "leschesl");
	// assert (auth.currentUser == user);
	// await MethodChannel('plugins.flutter.io/firebase_auth')
	// 	.invokeMethod(
	// 		"signInWithCredential",
	// 		{
	// 			"app": 
	// 			"username": "leschesl",
	// 			"password": "temp"
	// 		}
	// );
	// auth.signInWithRamaz("leschesl", "ramaz");
	AuthCredential creds = AuthCredential (
		"Ramaz", 
		{
			"username": "leschesl",
			"password": "temp"
		}
	);
	await auth.signInWithCredential(creds);
}