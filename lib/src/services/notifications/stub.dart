import "../notifications.dart";

/// The web implementation of a reminders notification. 
/// 
/// Notifications are not yet supported on web. 
Notification getReminderNotification({
	required String title, 
	required String message,
}) => Notification(title: title, message: message);

/// The web implementation of the [Notifications] service. 
/// 
/// Notifications are not yet supported on web. 
Notifications get notifications => StubNotifications();

/// The notifications service for the web.
/// 
/// Notifications are not yet supported on web. 
class StubNotifications extends Notifications {
	@override
	Future<void> init() async {}

	@override
	Future<void> signIn() async {}

	@override
	void sendNotification(Notification notification) {}

	@override
	void scheduleNotification({
		required Notification notification, 
		required DateTime date,
	}) {}

	@override
	void cancelAll() {}

	@override
	Future<List<String>> get pendingNotifications async => [];
}
