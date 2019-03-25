import "package:flutter/material.dart";

import "home.dart";
import "../mock.dart";
import "../backend/student.dart";

class Login extends StatefulWidget {
	@override LoginState createState() => LoginState();
}

class LoginState extends State <Login> {
	final FocusNode _userNode = FocusNode();
	final FocusNode _passwordNode = FocusNode();
	final TextEditingController _userController = TextEditingController();
	final TextEditingController _passController = TextEditingController();

	bool obscure = true;
	Student student;
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
		appBar: AppBar (title: Text ("Login")),
		floatingActionButton: FloatingActionButton.extended (
			onPressed: submit,
			icon: Icon (Icons.done),
			label: Text ("Submit")
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
										controller: _userController,
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
										controller: _passController,
										validator: passwordValidator,
										obscureText: obscure,
										onFieldSubmitted: submit,
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
						SizedBox (height: 30)  // FAB covers textbox when keyboard is up
					]
				)
			)
		)
	);

	String passwordValidator(String pass) => pass != pass.toLowerCase()
		? "All letters must be lowercase"
		: null;

	String usernameValidate(String text) => text.split (RegExp (r"[a-z]+")).any (
			(String region) => region.isNotEmpty
		)
			? "Only lower case letters allowed" 
			: null;

	void submit ([_]) {
		print ("""Submitted credentials: 
			User: ${_userController.text},
			Password: ${_passController.text}"""
		);
		Navigator.of(context).pushReplacement(
			MaterialPageRoute (
				// builder: (_) => HomePage (student)
				builder: (_) => HomePage (levi)
			)
		);
	}

	void transition ([String username]) {
		_userNode.unfocus();
		FocusScope.of(context).requestFocus(_passwordNode);
		lookupUsername();
	}

	void lookupUsername() => _userController.text.isEmpty 
		? null
		: setState (
			() {
				student = getStudent (_userController.text);
				userSuffix = student == null
					? Icon (Icons.error, color: Colors.red)
					: Icon (Icons.done, color: Colors.green);
			}
		);
}