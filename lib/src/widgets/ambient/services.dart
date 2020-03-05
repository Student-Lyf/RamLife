import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/services.dart";
import "package:ramaz/services_collection.dart";

/// An [InheritedWidget] that provides access to services in the widget tree. 
/// 
/// To get the Services widget, use `Services.of(context)`.
class Services extends InheritedWidget {
	/// Accesses the Services widget in the widget tree. 
	/// 
	/// Importantly, this function does not register [context] to depend on this 
	/// widget, since the services housed here are never updated. 
	static Services of(BuildContext context) => 
		context.findAncestorWidgetOfExactType<Services>();

	/// The collection of all services and models available. 
	/// 
	/// Additionally, this object is unpacked into other properties in this class. 
	final ServicesCollection services;

	/// Provides access to the device's file system. 
	/// 
	/// This is taken from [ServicesCollection.reader].
	final Reader reader;

	/// Provides access to small, key-value based variables on the device. 
	///  
	/// This is taken from [ServicesCollection.prefs].
	final Preferences prefs;

	/// Creates a services widget.
	/// 
	/// This constructor also unpacks [services] into more properties. 
	Services({
		@required Widget child,
		this.services,
	}) :
		reader = services.reader,
		prefs = services.prefs,
		super (child: child);

	/// A data model for reminders. 
	/// 
	/// This is taken from [ServicesCollection.reminders].
	Reminders get reminders => services.reminders;

	/// A data model for the schedule. 
	/// 
	/// This is taken from [ServicesCollection.schedule].
	Schedule get schedule => services.schedule;

	/// The admin data model for this user.
	/// 
	/// This will be null if the user is not an admin. 
	AdminModel get admin => services.admin;

	/// This instance will never be rebuilt with new data
	@override
	bool updateShouldNotify(_) => false;
}