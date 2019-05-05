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

	set subjectData (Map<int, Map<String, dynamic>> subjects) => subjectFile.writeAsStringSync (
		jsonEncode (
			// subjects
			subjects.map (
				(int id, Map<String, dynamic> json) => MapEntry (
					id.toString(), 
					json
				)
			)
		)
	);

	Map<int, Map<String, dynamic>> get subjectData => jsonDecode(
		subjectFile.readAsStringSync()
	).map (
		(String id, dynamic json) => MapEntry (
			int.parse(id),
			jsonDecode(json)
		)
	);

	Map<int, Subject> subjects;  // for efficient sharing

	void deleteAll() {
		if (studentFile.existsSync())
			studentFile.deleteSync();
	}

	bool get ready => studentFile.existsSync() && subjectFile.existsSync();

}
