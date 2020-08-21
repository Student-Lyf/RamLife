import "dart:convert" show JsonUnsupportedObjectError;
import "package:firebase_messaging/firebase_messaging.dart";

/// Callback that expects no arguments and returns no data. 
typedef VoidCallback = Future<void> Function();

// ignore: avoid_classes_with_only_static_members
/// An abstraction around Firebase Cloud Messaging. 
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
/// [registerNotifications], which assigns the same callback to all cases. 
/// The callbacks can be registered by passing in a map to 
/// [registerNotifications]. The value of the `command` field will be used as
/// the key to the map parameter. See [registerNotifications] for more details.
class FCM {
	static final FirebaseMessaging _firebase = FirebaseMessaging();

	/// A list of topics to subscribe to. 
	/// 
	/// Notifications sent with these topics will be received by the app. 
	static const List<String> topics = ["calendar", "sports"];

	/// Returns the device's FCM token
	static Future<String> get token => _firebase.getToken();

	/// Registers a group of callbacks with Firebase Cloud Messaging. 
	/// 
	/// The callbacks should be a map of command keys and functions. 
	/// The value of the `command` field of the data message will be passed
	/// as the key to the [commands]. This function should be called from a scope
	/// with access to data models and services. 
	static Future<void> registerNotifications(
		Map<String, VoidCallback> commands
	) async {
		// First, get permission on iOS:
		_firebase.requestNotificationPermissions();

		/// Calls the correct function based on the data message. 
		/// 
		/// This function handles validation of the notification and looks 
		/// up the correct callback function based on the command in the 
		/// data payload of the notification. 
		Future<void> callback(Map<String, dynamic> message) async {
			// DO NOT TRY TO GIVE THIS TYPE ARGUMENTS
			// For some reason adding Map<String, dynamic> won't let the code 
			// continue, not even throwing an error. I think I spent like an 
			// hour debugging this with 0 progress whatsoever. Attempt at 
			// your own risk, but you've been warned.
			final Map data = message["data"] ?? message;

			final String command = data ["command"];
			if (command == null) {
				throw JsonUnsupportedObjectError(
					message, 
					cause: "Data payload doesn't contain a 'command' field'",
					partialResult: data.toString(),
				);
			}

			// Same warning about types applies here. 
			final function = commands [command];
			if (function == null) {
				throw ArgumentError.value(
					command,
					"Command",
					"The 'command' field of the Firebase Cloud Message must be one of: "
						"${commands.keys.toList().join(", ")}"
				); 
			} else {
				await function();
			}
		}

		// Register the callback
		_firebase.configure(
			onMessage: callback,
			onResume: callback,
			onLaunch: callback,
		);
	}

	/// Subscribes to all the topics in [topics].
	static Future<void> subscribeToTopics() async {
		for (final String topic in topics) {
			await _firebase.subscribeToTopic(topic);
		}
	}
}
