import "package:meta/meta.dart";

import "notifications/stub.dart"
	if (dart.library.io) "notifications/mobile.dart";
import "service.dart";

/// A notification.
/// 
/// The notification has a [title] and a [message]. 
@immutable 
class Notification {
	/// The ID of this notification.
	/// 
	/// The ID is used for canceling the notifications. 
	static const int id = 0;

	/// The title of this notification.
	final String title;

	/// The body of this notification.
	final String message;

	/// Creates a notification. 
	const Notification({
		required this.title,
		required this.message,
	});

	/// Creates a notification for a reminder. 
	factory Notification.reminder({
		required String title, 
		required String message,
	}) => getReminderNotification(title: title, message: message);
}

/// The notifications service.
/// 
/// There are two types of notifications: local notifications, and push
/// notifications. Local notifications are sent by the app itself, and 
/// push notifications are sent by the server. These are local notifications. 
/// 
/// Local notifications can be customized to appear differently depending on
/// the type of notification and platform. They can also be scheduled to appear
/// at certain times.
/// 
/// Currently, Web is not supported. 
abstract class Notifications extends Service {
	/// The singleton instance for this service. 
	static Notifications instance = notifications;

	/// Sends a notification immediately. 
	void sendNotification(covariant Notification notification);

	/// Schedules a notification for [date]. 
	/// 
	/// [date] must not be in the past. 
	void scheduleNotification({
		required covariant Notification notification,
		required DateTime date
	});

	/// Cancels all notifications.
	void cancelAll();

	/// Notifications that are pending delivery. 
	Future<List<String>> get pendingNotifications;
}
