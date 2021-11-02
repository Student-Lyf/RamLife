// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";
import "package:flutter/services.dart" show PlatformException;

import "package:url_launcher/url_launcher.dart";

// ignore: directives_ordering
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
import "package:ramaz/widgets.dart";

/// The login page. 
/// 
/// This widget is only stateful so it doesn't get disposed when 
/// the theme changes, and then we can keep using the [BuildContext].
/// Otherwise, if the theme is changed, the [Scaffold] cannot be accessed. 
/// 
/// This page is the only page where errors from the backend are expected. 
/// As such, more helpful measures than simply closing the app are needed.
/// This page holds methods that can safely clean the errors away before
/// prompting the user to try again. 
class Login extends StatefulWidget {
	/// The page to navigate to after a successful login.
	final String destination;

	/// Builds the login page
	const Login({this.destination = Routes.home});

	@override 
	LoginState createState() => LoginState();
}

/// A state for the login page.
/// 
/// This state keeps a reference to the [BuildContext].
class LoginState extends State<Login> {
	/// Whether the page is loading. 
	bool isLoading = false;

	@override 
	void initState() {
		super.initState();
		// "To log in, one must first log out"
		// -- Levi Lesches, class of '21, creator of this app, 2019
		Services.instance.database.signOut();
		Models.instance.dispose();
	}

	@override
	Widget build (BuildContext context) => Scaffold (
		appBar: AppBar (
			title: const Text ("Login"),
			actions: [
				BrightnessChanger.iconButton(),
			],
		),
		body: Center(
			child: Column(
				children: [
					if (isLoading) const LinearProgressIndicator(minHeight: 8),
					const Spacer(flex: 2),
					SizedBox(
						height: 300, 
						width: 300, 
						child: ThemeChanger.of(context).brightness == Brightness.light
							? ClipRRect(
								borderRadius: BorderRadius.circular(20),
								child: RamazLogos.teal
							) : RamazLogos.ramSquareWords
					),
					// const SizedBox(height: 100),
					const Spacer(flex: 1),
					TextButton.icon(
						icon: Logos.google,
						label: const Text("Sign in with Google"),
						onPressed: () => signIn(context),
					),
					const Spacer(flex: 2),
				]
			)
		)
	);

	/// A function that runs whenever there is an error.
	/// 
	/// Unlike other screens, this screen can expect an error to be thrown by the 
	/// backend, so special care must be taken to present these errors in a 
	/// user-friendly way, while at the same time making sure they don't prevent 
	/// the user from logging in.
	Future<void> onError(dynamic error, StackTrace stack) async {
		setState(() => isLoading = false);
		final Crashlytics crashlytics = Services.instance.crashlytics;
		await crashlytics.log("Login failed");
		final String? email = Auth.email;
		if (email != null) {
			await crashlytics.setEmail(email);
		}
		// ignore: unawaited_futures
		showDialog (
			context: context,
			builder: (dialogContext) => AlertDialog (
				title: const Text ("Cannot connect"),
				content: const Text (
					"Due to technical difficulties, your account cannot be accessed.\n\n"
					"If the problem persists, please contact the Ramlife Dev Team "
					"for help" 
				),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(dialogContext).pop(),
						child: const Text ("Cancel"),
					),
					ElevatedButton(
						onPressed: () => launch("mailto:ramlife@ramaz.org"),
						child: const Text ("ramlife@ramaz.org"),
					)
				]
			)
		).then((_) async {		
			await Services.instance.database.signOut();
			Models.instance.dispose();
		});
		await crashlytics.recordError(error, stack);
	}

	/// Safely execute a function.
	/// 
	/// This function holds all the try-catch logic needed to properly debug
	/// errors. If a network error occurs, a simple [SnackBar] is shown. 
	/// Otherwise, the error pop-up is shown (see [onError]).
	Future<void> safely({
		required Future<void> Function() function, 
		required void Function() onSuccess,
		required BuildContext scaffoldContext,
	}) async {
		try {await function();} 
		on PlatformException catch (error, stack) {
			if (error.code == "ERROR_NETWORK_REQUEST_FAILED") {
				ScaffoldMessenger.of(scaffoldContext).showSnackBar(
					const SnackBar (content: Text ("No Internet")),
				);
				return setState(() => isLoading = false);
			} else {
				return onError(error, stack);
			}
		} on NoAccountException {
			return setState(() => isLoading = false);
		} catch (error, stack) {  // ignore: avoid_catches_without_on_clauses
			return onError(error, stack);
		}
		onSuccess();
	}

	/// Signs the user in. 
	/// 
	/// Calls [Services.signIn] and [Models.init]. 
	Future<void> signIn(BuildContext scaffoldContext) => safely(
		scaffoldContext: scaffoldContext,
		function: () async {
			setState(() => isLoading = true);
			await Services.instance.signIn();
			await Models.instance.init();
		},
		onSuccess: () {
			setState(() => isLoading = false);
			Navigator.of(context).pushReplacementNamed(widget.destination);
		},
	);
}
