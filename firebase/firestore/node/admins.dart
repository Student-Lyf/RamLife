import "package:firestore/helpers.dart";
import "package:firestore/services.dart";

Future<Map<String, List<String>>> getAdmins() async => {
	await for(final List<String> row in csvReadLines(DataFiles.admins))
		row [0]: row.sublist(1)
};

Future<void> setClaims(Map<String, List<String>> admins) async {
	for (final MapEntry<String, List<String>> entry in admins.entries) {
		assert(
			entry.value.every(Scopes.scopes.contains),
			"Cannot parse scopes for: ${entry.key}. Got: ${entry.value}"
		);
		Logger.verbose("setting claims for ${entry.key}");
		await Auth.setScopes(entry.key, entry.value);
	}
}

Future<void> main() async {
	Args.initLogger("Setting up admins...");

	if (Args.upload) {
		await Logger.logProgress(
			"setting admin claims",
			() async => setClaims(await Logger.logValue("admins", getAdmins))
		);
	}

	await app.delete();
	Logger.info("Finished setting up admins");
}
