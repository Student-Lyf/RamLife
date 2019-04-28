import "dart:async" show Future;
import "package:cloud_firestore/cloud_firestore.dart";

const String STUDENTS = "students";

final Firestore firestore = Firestore.instance;
final CollectionReference students = firestore.collection(STUDENTS);

Future<DocumentSnapshot> getStudent (String username) async => 
	await students.document(username).get();