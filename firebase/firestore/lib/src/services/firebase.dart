import "package:firebase_admin_interop/firebase_admin_interop.dart";

import "package:firestore/helpers.dart";

final File certificateFile = File("${projectDir.path}admin.json");

final FirebaseAdmin admin = FirebaseAdmin.instance;

final dynamic certificate = admin.certFromPath(certificateFile.path);

final App app = admin.initializeApp(
	AppOptions(
		credential: certificate,
		databaseURL: "https://console.firebase.google.com/project/ramaz-go",
	)
);
