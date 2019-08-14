import "package:flutter/foundation.dart" show required;
import 'package:firebase_messaging/firebase_messaging.dart';
import "dart:convert" show JsonUnsupportedObjectError;

import "package:ramaz/services/main.dart" show initOnLogin;
import "package:ramaz/services/reader.dart" show Reader;
import "package:ramaz/services/preferences.dart" show Preferences;
import "package:ramaz/services/auth.dart" as Auth;

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

final FirebaseMessaging firebase = FirebaseMessaging();

/// Convenience function to get the device's FCM token
Future<String> getToken() async => firebase.getToken();

/// Completely refresh the user's schedule 
/// Basically simulate the login sequence
void refresh(Reader reader, Preferences prefs) async {
	final String email = await Auth.getEmail();
	if (email == null) throw StateError(
		"Cannot refresh schedule because the user is not logged in."
	);
	initOnLogin(reader, prefs, email);
}

/// This one's kinda a tricky function
/// 
/// It needs to: 
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
Future<void> registerNotifications({
	@required Reader reader,
	@required Preferences prefs,	
}) async {

	// O(1) lookup table for the commands. 
	final Map<String, Command> commands = {
		"refresh": () => refresh(reader, prefs)
	};

	/// This function handles validation of the notification and looks 
	/// up the correct callback function based on the command in the 
	/// data payload of the notification. 
	Future<void> callback(Map<String, dynamic> message) async {
		print ("Message received!");
		final Map<String, dynamic> data = message["data"];
		if (data == null) throw JsonUnsupportedObjectError(
			message,
			cause: "No 'data' field in the message",
		);
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
		); else function();
	}

	// Register the callback
	firebase.configure(
		onMessage: callback,
		onResume: callback,
		onLaunch: callback,
	);
}
