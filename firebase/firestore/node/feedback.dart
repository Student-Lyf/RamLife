// @dart=2.9

import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/services.dart";

Future<void> main() async {
	Args.initLogger("Getting feedback");
	Logger.level = LogLevel.debug;

	final List<Feedback> feedback = await Firestore.getFeedback();

	feedback.sort(
		(Feedback a, Feedback b) => a.timestamp.compareTo(b.timestamp)
	);

	for (final Feedback message in feedback) {
		Logger.verbose("\t$message");
	}

	await app.delete();
	Logger.info("Feedback download complete");
}
