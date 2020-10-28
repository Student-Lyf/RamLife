import "../push_notifications.dart";

/// Provides the correct implementation for push notifications. 
/// 
/// Currently, Firebase Messaging is not supported on web, so this function 
/// provides a blank implementation. 
PushNotifications getPushNotifications() => PushNotificationsStub();

/// Receives push notifications using Firebase Messaging. 
/// 
/// Currently, Firebase Messaging does not support web. 
class PushNotificationsStub extends PushNotifications {
	@override
	Future<void> init() async {}

	@override
	Future<void> signIn() async {}

	@override
	Future<void> registerForNotifications(
		Map<String, AsyncCallback> callbacks
	) async {}

	@override
	Future<void> subscribeToTopics() async {}
}
