import "package:flutter/material.dart";

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/preferences.dart";
import "package:ramaz/services/services.dart";

class Services extends InheritedWidget {
	static Services of(
		BuildContext context, 
	) => context.inheritFromWidgetOfExactType(Services);

	final ServicesCollection services;
	final Reader reader;
	final Preferences prefs;

	Services({
		this.services,
		@required Widget child,
	}) :
		reader = services.reader,
		prefs = services.prefs,
		super (child: child);

	/// This instance will never be rebuilt with new data
	@override
	bool updateShouldNotify(_) => false;
}