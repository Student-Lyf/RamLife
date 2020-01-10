// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";
import "package:flutter/services.dart" show PlatformException;

import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:url_launcher/url_launcher.dart";

import "package:ramaz/widgets.dart";
import "package:ramaz/services_collection.dart";
import "package:ramaz/services.dart";

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
	/// The servces needed to log the user in. 
	final ServicesCollection services;

	/// Creates the login page. 
	const Login(this.services);

	@override LoginState createState() => LoginState();
}

/// A state for the login page.
/// 
/// This state keeps a reference to the [BuildContext].
class LoginState extends State<Login> {
	/// Rebuilds the widget tree when the loading bar dis/appears.
	final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);

	@override void initState() {
		super.initState();
		// "To log in, one must first log out"
		// -- Levi Lesches, class of '21, creator of this app, 2019
		Auth.signOut();
		widget.services.reader.deleteAll();
	}

	@override
	Widget build (BuildContext context) => ValueListenableBuilder(
		valueListenable: loadingNotifier,
		// ignore: sort_child_properties_last
		child: Padding (
			padding: const EdgeInsets.all (20),
			child: Column (
				children: [
					if (ThemeChanger.of(context).brightness == Brightness.light) ClipRRect(
						borderRadius: BorderRadius.circular (20),
						child: RamazLogos.teal
					)
					else RamazLogos.ramSquareWords, 
					const SizedBox (height: 50),
					Center (
						child: Container (
							decoration: BoxDecoration (
								border: Border.all(color: Colors.blue),
								borderRadius: BorderRadius.circular(20),
							),
							child: Builder (
								builder: (BuildContext context) => ListTile (
									leading: Logos.google,
									title: const Text ("Sign in with Google"),
									onTap: () => googleLogin(context)  // see func
								)
							)
						)
					)
				]
			)
		),
		builder: (BuildContext context, bool loading, Widget child) => Scaffold (
			appBar: AppBar (
				title: const Text ("Login"),
				actions: [
					BrightnessChanger.iconButton(prefs: widget.services.prefs),
				],
			),
			body: ListView (
				children: [
					if (loading) const LinearProgressIndicator(),
					child,
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
		loadingNotifier.value = false;
		await Crashlytics.instance.setUserEmail(await Auth.email);
		Crashlytics.instance.log("Attempting to log in...");
		await Crashlytics.instance.recordError(error, stack);

		await Auth.signOut();
		await showDialog (
			context: context,
			builder: (dialogContext) => AlertDialog (
				title: const Text ("Cannot connect"),
				content: const Text (
					"Due to technical difficulties, your account cannot be accessed.\n\n"
					"If the problem persists, please contact Levi Lesches "
					"(class of '21) for help" 
				),
				actions: [
					FlatButton (
						onPressed: () => Navigator.of(dialogContext).pop(),
						child: const Text ("Cancel"),
					),
					RaisedButton (
						onPressed: () => launch ("mailto:levilesches@gmail.com"),
						color: Theme.of(dialogContext).primaryColorLight,
						child: const Text ("levilesches@gmail.com"),
					)
				]
			)
		);
	}

	/// Safely execute a function.
	/// 
	/// This function holds all the try-catch logic needed to properly debug
	/// errors. If a network error occurs, a simple [SnackBar] is shown. 
	/// Otherwise, the error popup is shown (see [onError]).
	Future<void> safely({
		@required Future<void> Function() function, 
		@required void Function() onSuccess,
		@required BuildContext scaffoldContext,
	}) async {
		try {await function();} 
		on PlatformException catch (error, stack) {
			if (error.code == "ERROR_NETWORK_REQUEST_FAILED") {
				Scaffold.of(scaffoldContext).showSnackBar (
					const SnackBar (content: Text ("No internet")),
				);
				loadingNotifier.value = false;
				return;
			} else {
				await onError(error, stack);
				rethrow;
			}
		// ignore: avoid_catches_without_on_clauses
		} catch (error, stack) {
			await onError(error, stack);
			rethrow;
		}
		onSuccess();
	}

	/// Downloads the user data and initializes the app.
	/// 
	/// See [ServicesCollection.initOnLogin]. 
	Future<void> downloadData(
		String username, 
		BuildContext scaffoldContext
	) => safely(
		function: () => widget.services.initOnLogin(username),
		onSuccess: () => Navigator.of(context).pushReplacementNamed("home"),
		scaffoldContext: scaffoldContext,
	);
	
	/// Signs the user into their Google account.  	
	/// 
	/// If the user cancels the operation, cancel the loading animation. 
	/// Otherwise, download the user's data and start the main app. 
	/// See [downloadData].
	/// 
	/// This function needs two contexts. The first one can locate the
	/// [Scaffold]. But since that will rebuild (because of the loading bar), 
	/// we need another context that is higher up the tree than that.
	/// The tighter context is passed in as [scaffoldContext], and the higher
	/// context is [State.context]. 
		Future<void> googleLogin(BuildContext scaffoldContext) async => safely(
		function: Auth.signInWithGoogle,
		onSuccess: () async {
			loadingNotifier.value = true;
			final String email = await Auth.email;
			if (email == null) {
				loadingNotifier.value = false;
				return;
			}
			await downloadData(email.toLowerCase(), scaffoldContext);
		},
		scaffoldContext: scaffoldContext,
	);

}
