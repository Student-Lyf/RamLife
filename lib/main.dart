import "package:flutter/material.dart";
import "package:ramaz/services.dart";

import "app.dart";

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await FirebaseCore.initializeFirebase();
	runApp(const RamLife());
}
