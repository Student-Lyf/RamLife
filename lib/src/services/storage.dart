import "dart:convert" show jsonDecode, jsonEncode;
import "dart:io" show File;

import "service.dart";

/// An abstraction around the file system.
/// 
/// This class handles reading and writing JSON to and from files. 
/// Note that only raw data should be used with this class. Using 
/// dataclasses will create a dependency on the data library. 
class Storage implements Service {
	/// The path for this app's file directory.
	/// 
	/// Every app is provided a unique path in the file system by the OS. 
	/// Performing operations on files in this directory does not require
	/// extra permissions. In other words, data belonging exclusively to
	/// an app should reside in its given directory.  
	final String dir;
	
	/// The file containing the user's schedule.
	final File userFile;

	/// The file containing data for all the classes in the user's schedule.
	final File subjectFile;

	/// The file containing the calendar. 
	final File calendarFile;

	/// The file containing the user's reminders. 
	final File remindersFile;

	/// The file containing the admin profile. 
	final File adminFile;

	/// The file containing the sports games. 
	final File sportsFile;

	/// Initializes the files based on the path ([dir]) provided to it. 
	Storage(this.dir) :
		userFile = File("$dir/student.json"),
		subjectFile = File("$dir/subjects.json"),
		calendarFile = File("$dir/calendar.json"),
		adminFile = File("$dir/admin.json"),
		sportsFile = File("$dir/sports.json"),
		remindersFile = File("$dir/reminders.json");

	@override
	bool get isReady => userFile.existsSync()
		&& subjectFile.existsSync()
		&& calendarFile.existsSync()
		&& remindersFile.existsSync()
		&& adminFile.existsSync()
		&& sportsFile.existsSync();

	@override
	Future<void> reset() async {
		if (userFile.existsSync()) {
			userFile.deleteSync();
		}
		if (subjectFile.existsSync()) {
			subjectFile.deleteSync();
		}
		if (calendarFile.existsSync()) {
			calendarFile.deleteSync();
		}
		if (remindersFile.existsSync()) {
			remindersFile.deleteSync();
		}
		if (adminFile.existsSync()) {
			adminFile.deleteSync();
		}
		if (sportsFile.existsSync()) {
			sportsFile.deleteSync();
		}
	}

	@override
	Future<void> initialize() async {
		// No-op -- Files are always ready for writing
	}

	@override 
	Future<Map<String, dynamic>> get user async => jsonDecode(
		await userFile.readAsString()
	);

	@override
	Future<void> setUser(Map<String, dynamic> json) => 
		userFile.writeAsString(jsonEncode(json));

	@override
	Future<Map<String, Map<String, dynamic>>> getSections(_) async => 
		jsonDecode(await subjectFile.readAsString()).map(
			(String id, dynamic json) => 
				MapEntry(id, Map<String, dynamic>.from(json))	
		);

	@override
	Future<void> setSections(Map<String, Map<String, dynamic>> json) => 
		subjectFile.writeAsString(jsonEncode(json));

	@override
	Future<List<List<Map<String, dynamic>>>> get calendar async => [
		for (final List entry in jsonDecode(await calendarFile.readAsString())) [
			for (final entry2 in entry) 
				Map<String, dynamic>.from(entry2)
		]
	];

	@override
	Future<void> setCalendar(int month, List<Map<String, dynamic>> json) async {
		final List<List<Map<String, dynamic>>> cal = await calendar 
			?? List.filled(12, null);
		cal [month - 1] = json;
		await calendarFile.writeAsString(jsonEncode(cal));
	}

	@override
	Future<List<Map<String, dynamic>>> get reminders async => [
		for (final dynamic json in jsonDecode(await remindersFile.readAsString()))
			Map<String, dynamic>.from(json)
	];

	@override
	Future<void> setReminders(List<Map<String, dynamic>> json) => 
		remindersFile.writeAsString(jsonEncode(json));

	@override
	Future<Map<String, dynamic>> get admin async =>
		jsonDecode(await adminFile.readAsString());

	@override 
	Future<void> setAdmin(Map<String, dynamic> json) => 
		adminFile.writeAsString(jsonEncode(json));

	@override
	Future<List<Map<String, dynamic>>> get sports async => 
		jsonDecode(await sportsFile.readAsString());

	@override
	Future<void> setSports(List<Map<String, dynamic>> json) => 
		sportsFile.writeAsString(jsonEncode(json));
}