import "push_notifications/stub.dart"
	if (dart.library.io) "push_notifications/mobile.dart";

import "service.dart";

/// Callback that expects no arguments and returns no data. 
typedef AsyncCallback = Future<void> Function();

/// An abstract wrapper around the notifications plugin. 
/// 
/// There are two types of notifications: local notifications, and push
/// notifications. Local notifications are sent by the app itself, and 
/// push notifications are sent by the server. These are push notifications. 
/// 
/// Push notifications can trigger certain callbacks based on the content of 
/// the notification. Use [registerForNotifications] to pass in callbacks and 
/// use [subscribeToTopics] to specify what types of notifications the app 
/// should be listening for. 
abstract class PushNotifications extends Service {
	/// The default implementation of [PushNotifications]. 
	static PushNotifications instance = getPushNotifications();

	/// Registers async callbacks with push notifications. 
	/// 
	/// Each push notification has a `command` field. This function uses the value
	/// of that field to find the correct function to run. 
	Future<void> registerForNotifications(Map<String, AsyncCallback> callbacks);

	/// Subscribes to certain topics. 
	/// 
	/// The server will notify the app when a notification is served to that topic.
	Future<void> subscribeToTopics();
}
