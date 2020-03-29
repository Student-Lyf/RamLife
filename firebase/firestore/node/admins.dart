import "package:firestore/helpers.dart";
import "package:firestore/services.dart";

Future<Map<String, List<String>>> getAdmins() async => {
	await for(final List<String> row in csvReadLines(DataFiles.admins))
		row [0]: row.sublist(1)
};

Future<void> main() async {
	Args.initLogger("Setting up admins...");

	final Map<String, List<String>> admins = await Logger.logValue(
		"admins", getAdmins
	);

	for (final MapEntry<String, List<String>> entry in admins.entries) {
		await Logger.logProgress(
			"setting claims for ${entry.key}",
			() => Auth.setScopes(entry.key, entry.value)
		);
	}
	await app.delete();
	Logger.info("Finished setting up admins");
}
