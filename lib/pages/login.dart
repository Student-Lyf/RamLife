import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";

import "package:ramaz/pages/home.dart";
import "package:ramaz/data/student.dart";

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/firestore.dart" as Firestore;
import "package:ramaz/services/auth.dart" as Auth;

class Login extends StatefulWidget {
	@override LoginState createState() => LoginState();
}

class LoginState extends State <Login> {
	static final RegExp usernameRegex = RegExp ("[a-z]+");
	static final RegExp passwordRegex = RegExp (r"([a-z]|\d)+");
	final FocusNode _passwordNode = FocusNode();
	final TextEditingController usernameController = TextEditingController();
	final TextEditingController passwordController = TextEditingController();
	final GlobalKey<ScaffoldState> key = GlobalKey();
	final GoogleSignIn google = GoogleSignIn (scopes: ["email"]);

	bool obscure = true, ready = false;
	Student student;
	String usernameError, passwordError;
	final Reader reader = Reader();

	@override void initState() {
		super.initState();
		Auth.signOut();  // To log in, one must first log out  --Levi
		reader.init().then ((_) => reader.deleteAll());
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
			icon: Icon (Icons.done),
			label: Text ("Submit"),
			backgroundColor: ready ? Colors.blue : Theme.of(context).disabledColor
		),
		body: Padding (
			padding: EdgeInsets.all (20),
			child: SingleChildScrollView (
				child: Column (
					children: [
						Stack (children: [
							SizedBox (
								child: Center (child: CircularProgressIndicator()),
								height: 300,
								width: 300
							),
							Image.asset ("images/logo.jpg"),
						]),
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
							leading: CircleAvatar (
								child: Image.asset ("images/google.png"),
							),
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
		final String username = usernameController.text;
		final String password = passwordController.text;
		await Auth.signIn(username, password);
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
		downloadData(account.email.split("@")[0]);
	}

	void downloadData(String username) async {
		final Map<String, dynamic> data = (await Firestore.getStudent(username)).data;
		Student student = Student.fromData(data);
		reader.student = student;
		Navigator.of(context).pushReplacement(
			MaterialPageRoute (
				builder: (_) => HomePage (student)
			)
		);

	}

}
