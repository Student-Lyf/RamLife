import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
import "package:ramaz/widgets.dart";

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
	late Future<void> initFuture;

	@override
	void initState() {
		super.initState();
		initFuture = init();
	}

	/// Initializes the app's backends. 
	/// 
	/// No-op if the backend is already initialized.
	Future<void> init() async {
		try {
			if (!Services.instance.isReady) {
				await Services.instance.init();
        if (!mounted) return;
				ThemeChanger.of(context).brightness = caseConverter<Brightness> (
					value: Services.instance.prefs.brightness,
					onTrue: Brightness.light,
					onFalse: Brightness.dark,
					onNull: MediaQuery.of(context).platformBrightness,
				);
			}

			if (Auth.isSignedIn && !Models.instance.isReady) {
				await Models.instance.init();
			}
		} catch (error, stack) {
			await Services.instance.crashlytics.log("Error. Disposing models");
			Models.instance.dispose();
      if (!mounted) return;
			if (widget.onError != null) {
				await Navigator.of(context).pushReplacementNamed(widget.onError!);
			}
			await Services.instance.crashlytics.recordError(error, stack);
		}
		if (!widget.isAllowed()) {
      if (!mounted) return;
			await Navigator.of(context).pushReplacementNamed(widget.onFailure);
		}
	}

	@override
	Widget build(BuildContext context) => FutureBuilder(
		future: initFuture,
		builder: (_, AsyncSnapshot<void> snapshot) => 
			snapshot.connectionState == ConnectionState.done
				? widget.child
				: ResponsiveScaffold(
					appBar: AppBar(title: const Text("Loading...")),
					body: const Center(child: CircularProgressIndicator()),
					drawer: const RamlifeDrawer(),
				),
	);
}
