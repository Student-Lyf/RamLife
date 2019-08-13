import 'package:firebase_messaging/firebase_messaging.dart';

// So basically, here's the gist with these things
// When the app is in the foreground, it's onMessage
// If not, then: 
// if it's in the background:
// 	if it's a notification, it's onResume
// 	otherwise it's a data message and it'll be onMessage
// if it's terminated: 
// 	if it's a notification: it's onLaunch
// 	otherwise it's a data message and it's onMessage

final FirebaseMessaging firebase = FirebaseMessaging();

Future<String> getToken() async => firebase.getToken();

Future<void> callback(Map<String, dynamic> message) async {
	print ("Message received!");
	print (message);
}

void registerNotifications() => firebase.configure(
	onMessage: callback,
	onResume: callback,
	onLaunch: callback
);
