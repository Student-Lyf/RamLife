import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/services.dart";
import "package:firestore/students.dart";

extension RegexMatcher on RegExp {
	bool fullyMatches(String str) {
		final String match = stringMatch(str);
		return match == str;
	}
}

bool isZoomReminder(Map<String, dynamic> reminder) => 
	reminder ["time"] ["type"] == "subject" &&
	reminder ["time"] ["repeats"] == true &&
	RegExp(r"\d{3}-\d{3}-\d{4}").fullyMatches(reminder ["message"] as String);

Future<void> printZoomReminders() async {
	for (final User user in (await StudentReader.getStudents()).values) {
		final document = Firestore.remindersCollection.document(user.email);
		final Map<String, dynamic> data = (await document.get()).data.toMap();
		final List<Map<String, dynamic>> reminders = [
			for (final dynamic reminder in data ["reminders"] ?? [])
				Map<String, dynamic>.from(reminder)
		];
		if (
			reminders == null || 
			reminders.isEmpty || 
			!reminders.any(isZoomReminder)
		) {
			continue;
		}

		Logger.debug(user.email, reminders);


		// await Firestore.deleteRemindersFromUser(
		// 	user.email, 
		// 	(Map<String, dynamic> reminder) => 
		// 		reminder ["time"] ["type"] == "subject" &&
		// 		reminder ["time"] ["repeats"] == true &&
		// 		RegExp(r"\d{3}-\d{3}-\d{4}").fullyMatches(reminder ["message"] as String),
		// );
	}
}

Future<void> main(List<String> args) async {
	Args.initLogger("Reading zoom reminders");	
	if (Args.upload) {
		await Logger.logProgress("zoom reminders search", printZoomReminders);
	} else {
		Logger.info("Did not read reminders. Use the --upload flag.");
	}
	await app.delete();
}
