import "dart:convert" show jsonDecode, jsonEncode;
import "dart:io" show File;

/// An abstraction around the file system.
/// 
/// This class handles reading and writing JSON to and from files. 
/// Note that only raw data should be used with this class. Using 
/// dataclasses will create a dependency on the data library. 
class Reader {
	/// The path for this app's file directory.
	/// 
	/// Every app is provided a unique path in the file system by the OS. 
	/// Performing operations on files in this directory does not require
	/// extra permissions. In other words, data belonging exclusively to
	/// an app should reside in its given directory.  
	final String dir;
	
	/// The file containing the user's schedule.
	final File studentFile;

	/// The file containing data for all the classes in the user's schedule.
	final File subjectFile;

	/// The file containing the calendar. 
	final File calendarFile;

	/// The file containing the user's reminders. 
	final File remindersFile;

	final File adminFile;

	/// Initializes the files based on the path ([dir]) provided to it. 
	Reader(this.dir) :
		studentFile = File ("$dir/student.json"),
		subjectFile = File ("$dir/subjects.json"),
		calendarFile = File ("$dir/calendar.json"),
		adminFile = File("$dir/admin.json"),
		remindersFile = File ("$dir/reminders.json");

	/// The JSON representation of the user's schedule.
	Map<String, dynamic> get studentData => jsonDecode (
		studentFile.readAsStringSync()
	);

	set studentData(Map<String, dynamic> data) => studentFile.writeAsStringSync(
		jsonEncode(data)
	);

	/// The JSON representation of the user's classes. 
	/// 
	/// The value returned is a map where the keys are the class IDs 
	/// and the values are JSON representations of the class. 
	Map<String, Map<String, dynamic>> get subjectData => jsonDecode(
		subjectFile.readAsStringSync()
	).map<String, Map<String, dynamic>> (
		(String id, dynamic json) => MapEntry (
			id,
			Map<String, dynamic>.from(jsonDecode(json))
		)
	);

	set subjectData (Map<String, Map<String, dynamic>> subjects) {
		subjectFile.writeAsStringSync (
			jsonEncode (
				subjects.map(
					(String id, Map<String, dynamic> json) => MapEntry(
						id.toString(), jsonEncode(json)
					)
				)
			)
		);
	}

	/// The JSON representation of the calendar. 
	List<List<Map<String, dynamic>>> get calendarData => [
		for (final List entry in jsonDecode(calendarFile.readAsStringSync())) <Map<String, dynamic>>[
			for (final entry2 in entry) 
				Map<String, dynamic>.from(entry2)
		]
	];

	set calendarData(
		List<List<Map<String, dynamic>>> data
	) => calendarFile.writeAsStringSync(jsonEncode(data));

	/// The JSON representation of the user's reminders.
	/// 
	/// This includes a list of the user's read reminders. 
	Map<String, dynamic> get remindersData => Map<String, dynamic>.from(
		jsonDecode(
			remindersFile.readAsStringSync()
		) ?? {}
	);

	set remindersData(Map<String, dynamic> data) => 
		remindersFile.writeAsStringSync(jsonEncode(data ?? {}));

	Map<String, dynamic> get adminData => jsonDecode(
		adminFile.readAsStringSync()
	);

	set adminData (Map<String, dynamic> data) => adminFile.writeAsStringSync(
		jsonEncode(data)
	);

	/// Deletes all files that contain user data. 
	/// 
	/// This function will be called in two placed: 
	/// 
	/// 1. To try to get rid of bugs. If setup fails all data is erased. 
	/// 2. To clean up after logoff. 
	void deleteAll() {
		if (studentFile.existsSync()) {
			studentFile.deleteSync();
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
	}

	/// Whether the files necessary are present. 
	/// 
	/// This helps the setup logic determine whether to proceed 
	/// to the main app or prompt the user to login. 
	bool get ready => 
		studentFile.existsSync() && subjectFile.existsSync() 
		&& remindersFile.existsSync() && calendarFile.existsSync();
}
