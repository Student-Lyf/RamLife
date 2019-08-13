import 'package:firebase_messaging/firebase_messaging.dart';

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