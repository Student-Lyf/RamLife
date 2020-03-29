import "package:firebase_admin_interop/firebase_admin_interop.dart";
import "package:firebase_admin_interop/js.dart" as js;

import "package:firestore/helpers.dart";

/// The Firebase admin instance. 
final FirebaseAdmin admin = FirebaseAdmin.instance;

/// The certificate as loaded by [admin].
final js.Credential certificate = admin.certFromPath(DataFiles.certificate);

/// The app instance for this project. 
final App app = admin.initializeApp(
	AppOptions(
		credential: certificate,
		databaseURL: "https://console.firebase.google.com/project/ramaz-go",
	)
);
