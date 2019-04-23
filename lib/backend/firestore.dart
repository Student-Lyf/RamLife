import "dart:async";

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;

import "../constants.dart";

final Firestore firestore = Firestore.instance;
final CollectionReference students = firestore.collection(STUDENTS);

Future<DocumentSnapshot> getStudent (String username, FirebaseUser user) async => 
	await students.document(username).get();