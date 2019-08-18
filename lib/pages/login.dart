import "package:flutter/material.dart";
import "package:flutter/services.dart" show PlatformException;

import "package:url_launcher/url_launcher.dart";

import "package:ramaz/widgets/icons.dart";
import "package:ramaz/widgets/theme_changer.dart";
import "package:ramaz/widgets/brightness_changer.dart" show BrightnessChanger;
import "package:ramaz/widgets/services.dart";

// Used to actually login
import "package:ramaz/services/auth.dart" as Auth;
// import "package:ramaz/services/reader.dart";
// import "package:ramaz/services/preferences.dart";
import "package:ramaz/services/services.dart";
import "package:ramaz/services/main.dart" show initOnLogin;

/// This widget is only stateful so it doesn't get disposed when 
/// the theme changes, and then we can keep using the BuildContext
class Login extends StatefulWidget {
	// final Reader reader;
	// final Preferences prefs;
	// const Login(this.reader, this.prefs);
	const Login();

	@override LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
	final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);
	ServicesCollection services;

	@override void initState() {
		super.initState();
		services = Services.of(context).services;
		
		// Log out first
		Auth.signOut();
		services.reader.deleteAll();
	}

	@override
	Widget build (BuildContext widgetContext) => ValueListenableBuilder(
		valueListenable: loadingNotifier,
		child: Padding (
			padding: EdgeInsets.all (20),
			child: Column (
				children: [
					ThemeChanger.of(widgetContext).brightness == Brightness.light 
						? ClipRRect (
							borderRadius: BorderRadius.circular (20),
							child: RamazLogos.teal
						)
						: RamazLogos.ram_square_words, 
					SizedBox (height: 50),
					Center (
						child: Container (
							decoration: BoxDecoration (
								border: Border.all(color: Colors.blue),
								borderRadius: BorderRadius.circular(20),
							),
							child: Builder (
								builder: (BuildContext context) => ListTile (
									leading: Logos.google,
									title: Text ("Sign in with Google"),
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
				title: Text ("Login"),
				actions: [
					BrightnessChanger.iconButton(prefs: services.prefs),
				],
			),
			body: ListView (
				children: [
					if (loading) LinearProgressIndicator(),
					child,
				]
			)
		)
	);

	void onError(BuildContext context) {
		loadingNotifier.value = false;
		showDialog (
			context: context,
			builder: (dialogContext) => AlertDialog (
				title: Text ("Cannot connect"),
				content: Text (
					"Due to technical difficulties, your account cannot be accessed.\n\n"
					"If the problem persists, please contact Levi Lesches "
					"(class of '21) for help" 
				),
				actions: [
					FlatButton (
						child: Text ("Cancel"),
						onPressed: Navigator.of(dialogContext).pop
					),
					RaisedButton (
						child: Text ("levilesches@gmail.com"),
						onPressed: () => launch ("mailto:levilesches@gmail.com"),
						color: Theme.of(dialogContext).primaryColorLight
					)
				]
			)
		);
	}

	void safely({
		@required Future<void> Function() function, 
		@required void Function() onSuccess,
		@required BuildContext scaffoldContext,
	}) async {
		try {await function();} 
		on PlatformException catch (error) {
			if (error.code == "ERROR_NETWORK_REQUEST_FAILED") {
				Scaffold.of(scaffoldContext).showSnackBar (
					SnackBar (content: Text ("No internet")),
				);
				loadingNotifier.value = false;
				return;
			} else {
				onError(context);
				rethrow;
			}
		} catch (error) {
			onError(context);
			rethrow;
		}
		onSuccess();
	}

	void downloadData(String username, BuildContext scaffoldContext) async => safely(
		function: () async => 
			// await initOnLogin(widget.reader, widget.prefs, username),
			await initOnLogin(services, username),
		onSuccess: () => Navigator.of(context).pushReplacementNamed("home"),
		scaffoldContext: scaffoldContext,
	);
	
	/// This function needs two contexts. The first one can locate the ambient 
	/// Scaffold. But since that will rebuild (because of loading = true), 
	/// we need another context that is higher up the tree than that.
	/// For that we use the implicit `BuildContext` with `StatefulWidget`
	void googleLogin(BuildContext scaffoldContext) async => safely(
		function: () async => Auth.signInWithGoogle(
			() => Scaffold.of(scaffoldContext).showSnackBar(
				SnackBar (
					content: Text ("You need to sign in with your Ramaz email")
				)
			)
		),
		onSuccess: () async {
			loadingNotifier.value = true;
			final String email = await Auth.getEmail();
			if (email == null) return;
			await downloadData(email.toLowerCase(), scaffoldContext);
		},
		scaffoldContext: scaffoldContext,
	);

}
