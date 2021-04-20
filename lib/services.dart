/// An abstraction over device services and data sources. 
/// 
/// The services library serves two purposes: 
/// 
/// 1. To abstract device functions. 
/// 
/// 	For example, device notifications can be abstracted away from the 
/// 	business logic to provide for a platform-agnostic implementation. 
/// 
/// 2. To abstract data sources: 
/// 	
/// 	For example, retrieving data from a database or file can be abstracted
/// 	to keep the app focused on the content of the data rather than how to 
/// 	properly access it. 
library ramaz_services;

import "src/services/crashlytics.dart";
import "src/services/databases.dart";
import "src/services/notifications.dart";
import "src/services/preferences.dart";
import "src/services/push_notifications.dart";
import "src/services/service.dart";

export "src/services/auth.dart";
export "src/services/cloud_db.dart";
export "src/services/crashlytics.dart";
export "src/services/database.dart";
export "src/services/databases.dart";
export "src/services/firebase_core.dart";
export "src/services/local_db.dart";
export "src/services/notifications.dart";
export "src/services/preferences.dart";
export "src/services/push_notifications.dart";
export "src/services/service.dart";

/// Bundles all the services. 
/// 
/// A [Service] has an [init] and a [signIn] function. This service serves
/// to bundle them all, so that you only need to call the functions of this 
/// service, and they will call all the other services' functions. 
class Services implements Service {
	/// The singleton instance of this class. 
	static Services instance = Services();

	/// The Crashlytics interface. 
	final Crashlytics crashlytics = Crashlytics.instance;

	/// The database bundle. 
	final Databases database = Databases();

	/// The local notifications interface. 
	/// 
	/// Local notifications come from the app and not a server. 
	final Notifications notifications = Notifications.instance;

	/// The push notifications interface.
	/// 
	/// Push notifications come from the server. 
	final PushNotifications pushNotifications = PushNotifications.instance;

	/// The shared preferences interface.
	/// 
	/// Useful for storing small key-value pairs. 
	final Preferences prefs = Preferences();

	/// All the services in a list. 
	/// 
	/// The functions of this service operate on these services. 
	late final List<Service> services;

	/// Whether the services are ready to use.
	bool isReady = false;

	/// Bundles services together. 
	/// 
	/// Also initializes [services].
	Services() { 
		services = [prefs, database, crashlytics, notifications];
	}

	@override
	Future<void> init() async {
		for (final Service service in services) {
			await service.init();
		}
		isReady = true;
	}

	@override
	Future<void> signIn() async {
		for (final Service service in services) {
			await service.signIn();
		}
	}
}
