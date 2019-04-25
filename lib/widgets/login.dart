import "package:flutter/material.dart";

import "home.dart";
import "../mock.dart";  // for logging in
import "../backend/firestore.dart" as Firestore;
import "../backend/auth.dart" as Auth;

class Login extends StatefulWidget {
	@override LoginState createState() => LoginState();
}

class LoginState extends State <Login> {
	static final RegExp usernameRegex = RegExp ("[a-z]+");
	static final RegExp passwordRegex = RegExp (r"([a-z]|\d)+");
	final FocusNode _userNode = FocusNode();
	final FocusNode _passwordNode = FocusNode();
	final TextEditingController usernameController = TextEditingController();
	final TextEditingController passwordController = TextEditingController();
	final GlobalKey<ScaffoldState> key = GlobalKey();

	bool obscure = true;
	bool student = false;
	bool ready = false;
	// bool ready = false;
	Icon userSuffix;  // goes after the username prompt

	@override void initState () {
		super.initState();
		_userNode.addListener (lookupUsername);
	}

	@override void dispose() {
		super.dispose();
		_userNode.dispose();
		_passwordNode.dispose();
	}

	@override
	Widget build (BuildContext context) => Scaffold(
		key: key,
		appBar: AppBar (title: Text ("Login")),
		floatingActionButton: FloatingActionButton.extended (
			onPressed: ready ? submit : null,
			icon: Icon (Icons.done),
			label: Text ("Submit"),
			backgroundColor: ready ? Colors.blue : Colors.grey
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
							Image.asset ("lib/logo.jpg"),
						]),
						Form (
							autovalidate: true,
							child: Column (
								children: [
									TextFormField (
										focusNode: _userNode,
										keyboardType: TextInputType.text,
										textInputAction: TextInputAction.next,
										onFieldSubmitted: transition,
										validator: usernameValidate,
										controller: usernameController,
										decoration: InputDecoration (
											icon: Icon (Icons.account_circle),
											labelText: "Username",
											helperText: "Enter your Ramaz username",
											suffix: userSuffix
										)
									),
									TextFormField (
										textInputAction: TextInputAction.done,
										focusNode: _passwordNode,
										controller: passwordController,
										validator: passwordValidator,
										obscureText: obscure,
										onFieldSubmitted: verify,
										decoration: InputDecoration (
											icon: Icon (Icons.security),
											labelText: "Password",
											helperText: "Enter your Ramaz password",
											suffixIcon: IconButton (
												icon: Icon (obscure 
													? Icons.visibility 
													: Icons.visibility_off
												),
												onPressed: () => setState (() {obscure = !obscure;})
											)
										)
									)
								]
							)
						),
						SizedBox (height: 30),  // FAB covers textbox when keyboard is up
						RaisedButton (
							child: Text ("Login"),
							onPressed: loginWithFirebase
						)
					]
				)
			)
		)
	);

	static bool capturesAll (String text, RegExp regex) {
		final Match match = regex?.matchAsPrefix(text);
		return match != null && match.end == text.length;
	}

	String passwordValidator (String pass) {
		if (pass.isEmpty) return null;
		else if (capturesAll(pass, passwordRegex)) {
			// verify();
			return null;
		} else return "Only lower case letters and numbers";
	}

	String usernameValidate(String text) {
		if (text.isEmpty) return null;
		else if (capturesAll(text, usernameRegex)) {
			return null;
		} else return "Only lower case letters allowed";
	}

	void submit ([_]) {
		if (!student) {
			key.currentState.showSnackBar (
				SnackBar (content: Text ("Invalid username"))
			);
			return;
		}
		else if (!verifyPassword (student, passwordController.text)) {
			key.currentState.showSnackBar(
				SnackBar (content: Text ("Incorrect password"))
			);
			return;
		}
		print ("""Submitted credentials: 
			User: ${usernameController.text},
			Password: ${passwordController.text}"""
		);
		Navigator.of(context).pushReplacement(
			MaterialPageRoute (
				builder: (_) => HomePage (levi)
			)
		);
	}

	void verify([_]) => setState(
		() => ready = (
			verifyUsername (usernameController.text) && 
			verifyPassword (student, passwordController.text)
		)
	);

	void transition ([String username]) {
		_userNode.unfocus();
		FocusScope.of(context).requestFocus(_passwordNode);
		lookupUsername();
	}

	void lookupUsername() {
		verify();
		setState (() {
			student = verifyUsername (usernameController.text);
			userSuffix = student == false
				? Icon (Icons.error, color: Colors.red)
				: Icon (Icons.done, color: Colors.green);
		});
	}

	void loginWithFirebase() async {
		final String username = usernameController.text;
		final String password = passwordController.text;
		await Auth.signin(username, password);
		final Map<String, dynamic> data = (await Firestore.getStudent(username)).data;
		print (data.entries);
	}
}
