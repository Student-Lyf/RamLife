import "dart:convert" show jsonDecode, jsonEncode;
import "dart:io" show File;

import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/student.dart";

class Reader {
	final String dir;
	final File studentFile, subjectFile, calendarFile;
	Reader(this.dir) :
		// The files end with 2 because there seems to 
		// be some sort of ghost data in the original
		studentFile = File ("$dir/student2.json"),
		subjectFile = File ("$dir/subjects2.json"),
		calendarFile = File ("$dir/calendar.json");

	set studentData(Map<String, dynamic> data) => studentFile.writeAsStringSync(
		jsonEncode(data)
	);

	Map<String, dynamic> get studentData => jsonDecode (
		studentFile.readAsStringSync()
	);

	Student student;

	set subjectData (Map<String, Map<String, dynamic>> subjects) => subjectFile.writeAsStringSync (
		jsonEncode (
			subjects.map (
				(String id, Map<String, dynamic> json) => MapEntry (
					id, 
					jsonEncode(json)
				)
			)
		)
	);

	Map<String, Map<String, dynamic>> get subjectData => jsonDecode(
		subjectFile.readAsStringSync()
	).map<String, Map<String, dynamic>> (
		(String id, dynamic json) => MapEntry (
			id,
			jsonDecode(json) as Map<String, dynamic>
		)
	);

	Map<String, Subject> subjects;

	set calendarData (Map<String, dynamic> data) => calendarFile.writeAsStringSync(
		jsonEncode(data)
	);

	Map<String, dynamic> get calendarData => jsonDecode(
		calendarFile.readAsStringSync()
	);

	Map<DateTime, Day> calendar;
	Day today;

	void deleteAll() {
		if (studentFile.existsSync())
			studentFile.deleteSync();
		if (subjectFile.existsSync())
			subjectFile.deleteSync();
	}

	bool get ready => studentFile.existsSync() && subjectFile.existsSync();

	// This next section is so that we can pass information between screens
	// remember that all navigation happens through RamazApp.routes
	Day currentDay;
	Period period;
	Subject get subject => subjects [period?.id];

}
