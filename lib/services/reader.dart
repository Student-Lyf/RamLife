import "dart:convert" show jsonDecode, jsonEncode;
import "dart:io" show File;

import "package:ramaz/data/schedule.dart" show Subject;
import "package:ramaz/data/student.dart";

class Reader {
	final String dir;
	final File studentFile, subjectFile;
	Reader(this.dir) :
		studentFile = File ("$dir/student.json"),
		subjectFile = File ("$dir/subjects.json");

	set studentData(Map<String, dynamic> data) => studentFile.writeAsStringSync(
		jsonEncode(data)
	);

	Map<String, dynamic> get studentData => jsonDecode (
		studentFile.readAsStringSync()
	);

	Student student;

	set subjectData (Map<int, Map<String, String>> subjects) => subjectFile.writeAsStringSync (
		jsonEncode (
			subjects.map (
				(int id, Map<String, String> json) => MapEntry (id, json)
			)
		)
	);

	Map<int, Map<String, String>> get subjectData => jsonDecode(
		subjectFile.readAsStringSync()
	);

	Map<int, Subject> subjects;  // for efficient sharing

	void deleteAll() {
		if (studentFile.existsSync())
			studentFile.deleteSync();
	}

	bool get ready => studentFile.existsSync() && subjectFile.existsSync();

}
