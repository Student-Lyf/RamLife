import "package:flutter/material.dart";
import "package:flutter/services.dart" show PlatformException;

// To display the logo
import "package:ramaz/widgets/icons.dart";

// Used to actually login
import "package:ramaz/services/reader.dart";
import "package:ramaz/services/auth.dart" as Auth;
import "package:ramaz/services/preferences.dart";
import "package:ramaz/services/main.dart" show initOnLogin;

class Login extends StatefulWidget {
	final Reader reader;
	final Preferences prefs;
	Login(this.reader, this.prefs);

	@override LoginState createState() => LoginState();
}

class LoginState extends State <Login> {
	static final RegExp usernameRegex = RegExp ("[a-z]+");
	static final RegExp passwordRegex = RegExp (r"([a-z]|\d)+");
	final TextEditingController usernameController = TextEditingController();
	final FocusNode userNode = FocusNode();
	final GlobalKey<ScaffoldState> key = GlobalKey();
	String usernameError, passwordError;

	@override void initState() {
		super.initState();
		Auth.signOut();  // To log in, one must first log out  --Levi
		widget.reader.deleteAll();
		userNode.addListener(verifyUser);
	}

	@override void dispose() {
		super.dispose();
		usernameController.dispose();
	}

	@override
	Widget build (BuildContext context) => Scaffold(
		key: key,
		appBar: AppBar (title: Text ("Login")),
		body: Padding (
			padding: EdgeInsets.all (20),
			child: SingleChildScrollView (
				child: Column (
					children: [
						RamazLogos.teal,
						DefaultTabController(
							length: 2,
							child: TabBarView (
								physics: NeverScrollableScrollPhysics(),
								children: [
									Column (
										children: [
											TextField(
												controller: usernameController,
												focusNode: userNode,
												textInputAction: TextInputAction.next,
												onChanged: validateUsername,
												onSubmitted: verifyUser,
												decoration: InputDecoration(
													icon: Icon (Icons.verified_user),
													labelText: "Username",
													hintText: "Enter your Ramaz username",
													errorText: usernameError,
													suffix: IconButton (
														icon: Icon (Icons.navigate_next),
														onPressed: verifyUser
													)
												)
											),
											Center (child: Text ("OR")),
											ListTile (
												leading: Logos.google,
												title: Text ("Sign in with Google"),
											)
										]
									),
									CircularProgressIndicator(),
								]
							)
						)
					]
				)
			)
		)
	);

	static bool capturesAll (String text, RegExp regex) => 
		text.isEmpty || regex.matchAsPrefix(text)?.end == text.length;

	// void passwordValidator (String pass) => setState(() {
	// 	passwordError = capturesAll (pass, passwordRegex)
	// 		? null
	// 		: "Only lower case letters and numbers allowed";
	// 	ready = pass.isNotEmpty && usernameController.text.isNotEmpty;
	// });

	void validateUsername(String text) {
		String error;
		if (text.contains("@"))
			error = "Do not enter your Ramaz email, just your username";
		else if (!capturesAll (text, usernameRegex))
			error = "Only lower case letters allowed";
		if (error != null) setState(() => usernameError = error);
	}

	void verifyUser([String username]) {
		// TODO: Check if user exists and has email set up
	}

	void transition ([String username]) => DefaultTabController.of(context).animateTo(1);

	void login () async {
		// final String username = usernameController.text;
		// try {await Auth.signIn(username, password);}
		// on PlatformException catch (error) {
		// 	switch (error.code) {
		// 		case "ERROR_USER_NOT_FOUND":
		// 			setState(() => usernameError = "User does not exist");
		// 			break;
		// 		case "ERROR_WRONG_PASSWORD": 
		// 			// Check if we can sign in with a password
		// 			if ((await Auth.getSignInMethods(username)).contains ("password")) 
		// 				setState(() => passwordError = "Invalid password");
		// 			else setState(
		// 				() => passwordError = "This account has no password -- sign in with Google."
		// 			);
		// 			break;
		// 		default: throw "Cannot handle error: ${error.code}";
		// 	}
		// 	return;
		// }
		// downloadData(username);
	}

	void googleLogin() async {
		final account = await Auth.signInWithGoogle(
			() => key.currentState.showSnackBar(
				SnackBar (
					content: Text ("You need to sign in with your Ramaz email")
				)
			)
		);
		if (account == null) return;
		downloadData(account.email.split("@")[0], google: true);
	}

	void downloadData(String username, {bool google = false}) async {
		if (google) key.currentState.showSnackBar(
			SnackBar (
				content: Text ("Make sure to use Google to sign in next time")
			)
		); 
		setState(() {
			loading = true;
			ready = true;
		});
		await initOnLogin(widget.reader, widget.prefs, username);
		Navigator.of(context).pushReplacementNamed("home");
	}

}
