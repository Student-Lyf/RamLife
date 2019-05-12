import "package:flutter/material.dart";
import "package:flutter/services.dart" show PlatformException;

// Data classes to store downloaded data
import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart";

// To display the logo
import "package:ramaz/widgets/icons.dart";

// Used to actually login
import "package:ramaz/services/reader.dart";
import "package:ramaz/services/firestore.dart" as Firestore;
import "package:ramaz/services/auth.dart" as Auth;

class Login extends StatefulWidget {
	final Reader reader;
	Login(this.reader);

	@override LoginState createState() => LoginState();
}

class LoginState extends State <Login> {
	static final RegExp usernameRegex = RegExp ("[a-z]+");
	static final RegExp passwordRegex = RegExp (r"([a-z]|\d)+");
	final FocusNode _passwordNode = FocusNode();
	final TextEditingController usernameController = TextEditingController();
	final TextEditingController passwordController = TextEditingController();
	final GlobalKey<ScaffoldState> key = GlobalKey();

	bool obscure = true, ready = false, loading = false;
	String usernameError, passwordError;

	@override void initState() {
		super.initState();
		Auth.signOut();  // To log in, one must first log out  --Levi
		widget.reader.deleteAll();
	}

	@override void dispose() {
		super.dispose();
		_passwordNode.dispose();
	}

	@override
	Widget build (BuildContext context) => Scaffold(
		key: key,
		appBar: AppBar (
			title: Text ("Login"),
		),
		floatingActionButton: FloatingActionButton.extended (
			onPressed: ready ? login : null,
			icon: loading ? CircularProgressIndicator() : Icon (Icons.done, color: Theme.of(context).accentColor),
			label: Text ("Submit", style: TextStyle(color: Theme.of(context).accentColor)),
			backgroundColor: ready && !loading
				? Theme.of(context).buttonColor
				: Theme.of(context).disabledColor
		),
		body: Padding (
			padding: EdgeInsets.all (20),
			child: SingleChildScrollView (
				child: Column (
					children: [
						RamazLogos.teal,
						TextField (
							keyboardType: TextInputType.text,
							textInputAction: TextInputAction.next,
							onSubmitted: transition,
							onChanged: usernameValidate,
							controller: usernameController,
							decoration: InputDecoration (
								icon: Icon (Icons.account_circle),
								errorText: usernameError,
								labelText: "Username",
								helperText: "Enter your Ramaz username",
							)
						),
						TextField (
							textInputAction: TextInputAction.done,
							focusNode: _passwordNode,
							controller: passwordController,
							onChanged: passwordValidator,
							obscureText: obscure,
							decoration: InputDecoration (
								icon: Icon (Icons.security),
								labelText: "Password",
								helperText: "Enter your Ramaz password",
								errorText: passwordError,
								suffixIcon: IconButton (
									icon: Icon (obscure 
										? Icons.visibility 
										: Icons.visibility_off
									),
									onPressed: () => setState (() {obscure = !obscure;})
								)
							)
						),
						SizedBox (height: 30),  // FAB covers textbox when keyboard is up
						ListTile (
							title: Text ("Sign in with Google"),
							onTap: googleLogin,
							contentPadding: EdgeInsets.symmetric (horizontal: 20),
							leading: Logos.google
						)
					]
				)
			)
		)
	);

	static bool capturesAll (String text, RegExp regex) => 
		text.isEmpty || regex.matchAsPrefix(text)?.end == text.length;

	void passwordValidator (String pass) => setState(() {
		passwordError = capturesAll (pass, passwordRegex)
			? null
			: "Only lower case letters and numbers allowed";
		ready = pass.isNotEmpty && usernameController.text.isNotEmpty;
	});

	void usernameValidate(String text) => setState(() {
		if (text.contains("@"))
			usernameError = "Do not enter your Ramaz email, just your username";
		else if (capturesAll (text, usernameRegex)) usernameError = null;
		else usernameError = "Only lower case letters allowed";
		ready = text.isNotEmpty && passwordController.text.isNotEmpty; 
	});

	void transition ([String username]) => FocusScope.of(context)
		.requestFocus(_passwordNode);

	void login () async {
		_passwordNode.unfocus();
		final String username = usernameController.text;
		final String password = passwordController.text;
		try {await Auth.signIn(username, password);}
		on PlatformException catch (error) {
			switch (error.code) {
				case "ERROR_USER_NOT_FOUND":
					setState(() => usernameError = "User does not exist");
					break;
				case "ERROR_WRONG_PASSWORD": 
					// Check if we can sign in with a password
					if ((await Auth.getSignInMethods(username)).contains ("password")) 
						setState(() => passwordError = "Invalid password");
					else setState(
						() => passwordError = "This account has no password -- sign in with Google."
					);
					break;
				default: throw "Cannot handle error: ${error.code}";
			}
			return;
		}
		downloadData(username);
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
		final Map<String, dynamic> data = (await Firestore.getStudent(username)).data;
		widget.reader.studentData = data;
		widget.reader.student = Student.fromData(data);

		final Map<int, Map<String, dynamic>> subjectData = 
			await Firestore.getClasses(widget.reader.student);
		widget.reader.subjectData = subjectData;
		final Map<int, Subject> subjects = Subject.getSubjects(subjectData);
		widget.reader.subjects = subjects;

		Navigator.of(context).pushReplacementNamed("home");
	}

}
