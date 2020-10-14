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
/// 
library ramaz_services;

import "src/services/crashlytics.dart";
import "src/services/databases.dart";
import "src/services/notifications.dart";
import "src/services/preferences.dart";
import "src/services/push_notifications.dart";
import "src/services/service.dart";

export "src/services/auth.dart";
export "src/services/crashlytics.dart";
export "src/services/notifications.dart";
export "src/services/preferences.dart";

class Services implements Service {
	/// The singleton instance of this class. 
	static Services instance = Services();

	final Crashlytics crashlytics = Crashlytics.instance;
	final Databases database = Databases();
	final Notifications notifications = Notifications();
	final PushNotifications pushNotifications = PushNotifications.instance;
	final Preferences prefs = Preferences();

	List<Service> services;

	/// Bundles services together. 
	/// 
	/// Also initializes [services].
	Services() {
		services = [prefs, database, crashlytics, notifications, pushNotifications];
	}

	@override
	Future<void> init() async {
		for (final Service service in services) {
			await service.init();
		}
	}

	@override
	Future<void> signIn() async {
		for (final Service service in services) {
			await service.signIn();
		}
	}
}
