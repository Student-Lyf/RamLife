import "package:flutter/material.dart";
import "package:flutter/services.dart" show PlatformException;

import "package:ramaz/widgets/icons.dart";
import "package:ramaz/widgets/theme_changer.dart";

// Used to actually login
import "package:ramaz/services/reader.dart";
import "package:ramaz/services/auth.dart" as Auth;
import "package:ramaz/services/preferences.dart";
import "package:ramaz/services/dynamic_links.dart" as DynamicLinks;
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
	final PageController pageController = PageController();
	final TextEditingController usernameController = TextEditingController();
	final FocusNode userNode = FocusNode();
	final GlobalKey<ScaffoldState> key = GlobalKey();

	String usernameError, passwordError;
	bool loading = false, ready = false;

	@override void initState() {
		DynamicLinks.getLink().then (
			(Uri uri) {
				if (uri == null) 
					print ("There is no dynamic link");
				else {
					print (uri.toString());
					print (Auth.isSignInLink(uri.toString()));
				}
			}
		);
		super.initState();
		Auth.signOut();  // To log in, one must first log out  --Levi
		widget.reader.deleteAll();
		// usernameController.text = "Coming soon";  // TODO
	}

	@override void dispose() {
		super.dispose();
		usernameController.dispose();
	}

	@override
	Widget build (BuildContext context) => Scaffold(
		key: key,
		appBar: AppBar (title: Text ("Login")),
		body: ListView (  // for keyboard blocking the screen
			shrinkWrap: true,  // solves everything
			children: [
				if (loading) LinearProgressIndicator(),
				Padding (
					padding: EdgeInsets.all (20),
					child: Column (
						children: [
							ThemeChanger.of(context).brightness == Brightness.light 
								? RamazLogos.teal
								: RamazLogos.ram_square_words, 
							TextField(
								controller: usernameController,
								focusNode: userNode,
								textInputAction: TextInputAction.done,
								onChanged: validateUsername,
								onSubmitted: login,
								decoration: InputDecoration(
									enabled: false,
									icon: Icon (Icons.verified_user),
									labelText: "Username",
									hintText: "Enter your Ramaz username",
									errorText: usernameError,
									suffix: IconButton (
										icon: Icon (Icons.done),
										onPressed: ready ? login : null,
										color: Colors.green,
									)
								)
							),
							SizedBox (height: 20),
							Center (child: Text ("OR", textScaleFactor: 1)),
							SizedBox (height: 10),
							ListTile (
								leading: Logos.google,
								title: Text ("Sign in with Google"),
								onTap: googleLogin
							)
						]
					)
				)
			]
		)
	);

	static bool capturesAll (String text, RegExp regex) => 
		text.isEmpty || regex.matchAsPrefix(text)?.end == text.length;

	void validateUsername(String text) {
		String error;
		ready = text.isNotEmpty;
		if (text.contains("@"))
			error = "Do not enter your Ramaz email, just your username";
		else if (!capturesAll (text, usernameRegex))
			error = "Only lower case letters allowed";
		else error = null;
		if (error != null) ready = false;
		setState(() => usernameError = error);
	}

	void login ([String username]) async {
		// TODO: Check if user exists and has email set up
		userNode.unfocus();
		await Auth.signInWithEmail("leschesl@ramaz.org");
		// downloadData(username ?? usernameController.text);

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
		setState(() => loading = true);
		if (google) key.currentState.showSnackBar(
			SnackBar (
				content: Text ("Make sure to use Google to sign in next time")
			)
		); 
		try {await initOnLogin(widget.reader, widget.prefs, username);}
		on PlatformException {
			setState(() => loading = false);
			key.currentState.showSnackBar(
				SnackBar (content: Text ("Login failed"))
			);
			return;
		}
		Navigator.of(context).pushReplacementNamed("home");
	}

}
