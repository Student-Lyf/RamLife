import 'package:firebase_messaging/firebase_messaging.dart';
import "dart:convert" show JsonUnsupportedObjectError;

/// Callback that expects no arguments and returns no data. 
typedef VoidCallback = void Function();

/// An abstraction around Firebase Cloud Messaging. 
/// 
/// The app can receive a notification from Firebase at any time.
/// What it does with the notification depends on when it was received:
/// 
/// 	- If the app is in the foreground, `onMessage` is called. 
/// 	- If the app is in the background: 
/// 		- If it's a notification, `onResume` is called when the app starts.
/// 		- Otherwise, `onMessage` is called.
/// 	- If the app is terminated, `onLaunch` will be called when the app is opened.
/// 
/// In any case, noticication configuration is handled by [registerNotifications], 
/// which assigns the same callback to all cases. The callbacks can be registered 
/// by passing in a map to [registerNotifications]. The value of the `command` 
/// field will be used as the key to the map parameter. See [registerNotifications]
/// for more details.  
class FCM {
	static final FirebaseMessaging _firebase = FirebaseMessaging();

	/// Returns the device's FCM token
	static Future<String> getToken() async => _firebase.getToken();

	/// Registers a group of callbacks with Firebase Cloud Messaging. 
	/// 
	/// The callbacks should be a map of command keys and functions. 
	/// The value of the `command` field of the data message will be passed
	/// as the key to the [commands]. This function should be called from main. 
	static Future<void> registerNotifications(Map<String, VoidCallback> commands) async {
		// First, get permission on iOS:
		_firebase.requestNotificationPermissions();

		/// Calls the correct function based on the data message. 
		/// 
		/// This function handles validation of the notification and looks 
		/// up the correct callback function based on the command in the 
		/// data payload of the notification. 
		Future<void> callback(Map<String, dynamic> message) async {
			print ("Message received!");
			// DO NOT TRY TO GIVE THIS TYPE ARGUMENTS
			// For some reason adding Map<String, dynamic> won't let the code 
			// continue, not even throwing an error. I think I spent like an 
			// hour debugging this with 0 progress whatsoever. Attempt at 
			// your own risk, but you've been warned.
			final Map data = message["data"] ?? message;

			final String command = data ["command"];
			if (command == null) throw JsonUnsupportedObjectError(
				message, 
				cause: "Data payload doesn't contain a 'command' field'",
				partialResult: data.toString(),
			);

			final VoidCallback function = commands [command];
			if (function == null) throw ArgumentError.value(
				command,
				"Command",
				"The 'command' field of the Firebase Cloud Message must be one of: " + 
					commands.keys.toList().join(", "),
			); else {
				print ("Executing command: $command");
				await function();
				print ("Command successfully executed.");
			}
		}

		// Register the callback
		_firebase.configure(
			onMessage: callback,
			onResume: callback,
			onLaunch: callback,
		);
	}

	/// Subscribe to the calendar. 
	/// 
	/// Calling this function will result in being notified when the calendar changes. 
	/// This allows the device to only update the calendar and not all of the student 
	/// data. Notifications are still handled by [registerNotifications].
	static Future<void> subscribeToCalendar() async => _firebase.subscribeToTopic("calendar");

	/// Subscribe to a publication.
	/// 
	/// Calling this function will result in being notified when the authors 
	/// publish a new issue or edit a past issue. This way, all users will stay
	/// updated at the author's whim, while still only following some publications.
	static Future<void> subscribeToPublication(String publication, bool value) => value
		? _firebase.subscribeToTopic("publication-$publication")
		: _firebase.unsubscribeFromTopic("publication-$publication");
}
