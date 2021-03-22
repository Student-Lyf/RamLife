import "package:flutter/material.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/models.dart";
import "package:ramaz/services.dart";

class RouteInitializer extends StatefulWidget {
	static bool alwaysTrue () => true;

	final bool Function() isAllowed;
	final WidgetBuilder builder;
	final String onFailure;
	final String onError;

	const RouteInitializer({
		@required this.builder,
		this.onFailure = Routes.login,
		this.onError = Routes.login,
		this.isAllowed = alwaysTrue,
	});

	@override 
	RouteInitializerState createState() => RouteInitializerState();
}

class RouteInitializerState extends State<RouteInitializer> {
	Future initFuture;

	@override
	void initState() {
		super.initState();
		initFuture = init();
	}

	Future<void> init() async {
		final NavigatorState nav = Navigator.of(context);
		try {
			await Services.instance.init();
			if (Auth.isSignedIn) {
				await Models.instance.init();
			}
		} catch (error) {  //
			await nav.pushReplacementNamed(widget.onError);
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
				? widget.builder(context) 
				: const Center(child: CircularProgressIndicator())
	);
}