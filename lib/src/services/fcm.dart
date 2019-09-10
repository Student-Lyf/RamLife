import 'package:firebase_messaging/firebase_messaging.dart';
import "dart:convert" show JsonUnsupportedObjectError;

// So basically, here's the gist with these things
// When the app is in the foreground, it's onMessage
// If not, then: 
// if it's in the background:
// 	if it's a notification, it's onResume
// 	otherwise it's a data message and it'll be onMessage
// if it's terminated: 
// 	if it's a notification: it's onLaunch
// 	otherwise it's a data message and it's onMessage

typedef Command = void Function();

class FCM {
	static const String calendarTopic = "calendar";
	static const String publicationTopic = "publication";

	static final FirebaseMessaging firebase = FirebaseMessaging();

	/// Convenience function to get the device's FCM token
	static Future<String> getToken() async => firebase.getToken();

	/// This one's kinda a tricky function
	/// 
	/// It needs to: 
	/// 
	/// 	a. register a callback with Firebase Cloud Messaging services
	/// 	b. Define that callback function to utitlize backend objects
	/// 	c. Provide a table to look up the correct callback function 
	/// 
	/// This is accomplished by defining the callback function inside this 
	/// function. This allows it to use the backend objects without much
	/// bookkeeping. Since this function is only going to be called once, 
	/// this inefficiency is taken care of. 
	/// 
	/// The command functions are declared globally instead of the manner
	/// described above in order to make extension much simpler. 
	static Future<void> registerNotifications(Map<String, Command> commands) async {
		// First, get permission on iOS:
		firebase.requestNotificationPermissions();

		/// This function handles validation of the notification and looks 
		/// up the correct callback function based on the command in the 
		/// data payload of the notification. 
		Future<void> callback(Map<String, dynamic> message) async {
			print ("Message received!");
			// DO NOT TEY TO GIVE THIS TYPE ARGUMENTS
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

			final Command function = commands [command];
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
		firebase.configure(
			onMessage: callback,
			onResume: callback,
			onLaunch: callback,
		);
	}

	static Future<void> subscribeToCalendar(bool value) async => value 
		? firebase.subscribeToTopic(calendarTopic)
		: firebase.unsubscribeFromTopic(calendarTopic);

	static Future<void> subscribeToPublication(String publication, bool value) => value
		? firebase.subscribeToTopic("$publicationTopic-$publication")
		: firebase.unsubscribeFromTopic("$publicationTopic-$publication");
}
