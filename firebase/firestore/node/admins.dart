// @dart=2.9

import "package:firestore/helpers.dart";
import "package:firestore/services.dart";

Future<Map<String, List<String>>> getAdmins() async => {
	await for(final List<String> row in csvReadLines(DataFiles.admins))
		row [0]: row.sublist(1)
};

Future<void> setClaims(Map<String, List<String>> admins) async {
	for (final MapEntry<String, List<String>> entry in admins.entries) {
		final String email = entry.key;
		final List<String> scopes = entry.value;
		if (!scopes.every(Scopes.scopes.contains)) {
			throw ArgumentError.value(
				scopes.toString(), 
				"admin scopes", 
				"Unrecognized scopes for $email"
			);
		}
		Logger.verbose("Setting claims for $email");
		if (entry.value.isEmpty) {
			Logger.warning("Removing admin privileges for $email");
		}
		await Logger.logValue<Map<String, dynamic>>(
			"Previous claims for $email", () => Auth.getClaims(email)
		);
		await Auth.setScopes(email, scopes);
	}
}

Future<void> main() async {
	Args.initLogger("Setting up admins...");

	// Log the value whether or not --upload is passed.
	final Map<String, List<String>> admins = 
		await Logger.logValue("admins", getAdmins);

	if (Args.upload) {
		await setClaims(admins);
	} else {
		Logger.warning("Did not upload admin claims. Use the --upload flag.");
	}

	await app.delete();
	Logger.info("Finished setting up admins");
}
