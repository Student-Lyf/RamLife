import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging firebase = FirebaseMessaging();

void getToken() async => firebase.getToken();