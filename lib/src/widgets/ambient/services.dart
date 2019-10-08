import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/services.dart";
import "package:ramaz/services_collection.dart";

class Services extends InheritedWidget {
	static Services of(
		BuildContext context, 
	) => context.inheritFromWidgetOfExactType(Services);

	final ServicesCollection services;
	final Reader reader;
	final Preferences prefs;

	Services({
		@required Widget child,
		this.services,
	}) :
		reader = services.reader,
		prefs = services.prefs,
		super (child: child);

	Reminders get reminders => services.reminders;
	Schedule get schedule => services.schedule;

	/// This instance will never be rebuilt with new data
	@override
	bool updateShouldNotify(_) => false;
}