import "dart:convert" show JsonUnsupportedObjectError;
import "package:firebase_messaging/firebase_messaging.dart";

import "../firebase_core.dart";
import "../push_notifications.dart";

/// Provides the correct implementation for push notifications. 
/// 
/// On mobile, uses Firebase Messaging. 
PushNotifications getPushNotifications() => FCM();

/// Receives push notifications using Firebase Messaging. 
/// 
/// The app can receive a notification from Firebase at any time.
/// What it does with the notification depends on when it was received:
/// 
/// - If the app is in the foreground, `onMessage` is called. 
/// - If the app is in the background: 
/// 	- If it's a notification, `onResume` is called when the app starts.
/// 	- Otherwise, `onMessage` is called.
/// - If the app is terminated, `onLaunch` will be called when the app is 
/// 	opened.
/// 
/// In any case, notification configuration is handled by 
/// [registerForNotifications], which assigns the same callback to all cases. 
/// The callbacks can be registered by passing in a map to 
/// [registerForNotifications]. 
/// 
/// The value of the `command` field of the notification will be used as
/// the key to the map parameter. See [callback] for details.
class FCM extends PushNotifications {
	/// A list of topics to subscribe to. 
	/// 
	/// Notifications sent with these topics will be received by the app. 
	static const List<String> topics = ["calendar", "sports"];

	/// Provides the connection to Firebase Messaging. 
	static final FirebaseMessaging firebase = FirebaseMessaging.instance;

	/// Maps command payloads to async functions. 
	late Map<String, AsyncCallback> callbacks;

	@override
	Future<void> init() async {
		await FirebaseCore.init();
		await registerForNotifications(
			{
				// "refresh": initialize,
				// "updateCalendar": updateCalendar,
				// "updateSports": updateSports,
			}
		);
		await subscribeToTopics();
	}

	@override
	Future<void> signIn() async => firebase.requestPermission();

	/// A callback to handle any notification. 
	/// 
	/// This function uses the `command` field of the notification to find the 
	/// right [AsyncCallback], and calls it. 
	Future<void> callback(
		Map<String, dynamic> message, 
	) async {
		final String? command = (message["data"] ?? message) ["command"];
		if (command == null) {
			throw JsonUnsupportedObjectError(
				message, 
				cause: "Data payload doesn't contain a 'command' field'",
				partialResult: message.toString(),
			);
		}
		final AsyncCallback? function = callbacks [command];
		if (function == null) {
			throw ArgumentError.value(
				command,
				"Command",
				"The 'command' field of the Firebase Cloud Message must be one of: "
					"${callbacks.keys.toList().join(", ")}"
			); 
		}
		await function();
	}

	@override
	Future<void> registerForNotifications(
		Map<String, AsyncCallback> callbacks
	) async {
		this.callbacks = callbacks;

		FirebaseMessaging.onBackgroundMessage((message) => callback(message.data));
		// replace with FirebaseMessaging.onMessage.listen(callback)
		// firebase.configure( 
		// 	onMessage: callback,
		// 	onLaunch: callback,
		// 	onResume: callback,
		// );
	}

	/// Subscribes to all the topics in [topics].
	@override
	Future<void> subscribeToTopics() async {
		for (final String topic in topics) {
			await firebase.subscribeToTopic(topic);
		}
	}
}
