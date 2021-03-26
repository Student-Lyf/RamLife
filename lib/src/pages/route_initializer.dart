import "package:flutter/material.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/models.dart";
import "package:ramaz/services.dart";

/// A route that performs initialization logic first.
class RouteInitializer extends StatefulWidget {
	/// Checks to see if the user is signed in.
	/// 
	/// This is the default logic to determine if the user can access a page.
	static bool isSignedIn() => Auth.isSignedIn;

	/// Determines if the user is allowed to be on the given page.
	final bool Function() isAllowed;

	/// The contents of the page. 
	final Widget child;

	/// The route to navigate to if the user is not authorized.
	final String onFailure;
	
	/// The route to navigate to if there is an error.
	final String? onError;

	/// Navigation with authorization and error-handling.
	const RouteInitializer({
		required this.child,
		this.onFailure = Routes.login,
		this.onError = Routes.login,
		this.isAllowed = isSignedIn,
	});

	@override 
	RouteInitializerState createState() => RouteInitializerState();
}

/// The state for a [RouteInitializer].
class RouteInitializerState extends State<RouteInitializer> {
	/// The future for initializing the backend.
	late Future initFuture;

	@override
	void initState() {
		super.initState();
		initFuture = init();
	}

	/// Initializes the app's backends. 
	/// 
	/// No-op if the backend is already initialized.
	Future<void> init() async {
		final NavigatorState nav = Navigator.of(context);
		try {
			await Services.instance.init();
			if (Auth.isSignedIn && !Models.instance.isReady) {
				await Models.instance.init();
			}				
		} catch (error) {
			await Services.instance.crashlytics.log("Error. Disposing models");
			Models.instance.dispose();
			if (widget.onError != null) {
				await nav.pushReplacementNamed(widget.onError!);
			}
		}
		if (!widget.isAllowed()) {
			await nav.pushReplacementNamed(widget.onFailure);
		}
	}

	@override
	Widget build(BuildContext context) => FutureBuilder(
		future: initFuture,
		builder: (_, AsyncSnapshot snapshot) => 
			snapshot.connectionState == ConnectionState.done
				? widget.child
				: const Center(child: CircularProgressIndicator())
	);
}
