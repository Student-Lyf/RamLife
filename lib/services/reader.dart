import "dart:convert" show jsonDecode, jsonEncode;
import "dart:io" show File;

import "package:ramaz/data/schedule.dart" show Subject;
import "package:ramaz/data/student.dart";

class Reader {
	final String dir;
	final File studentFile, subjectFile;
	Reader(this.dir) :
		// The files end with 2 because there seems to 
		// be some sort of ghost data in the original
		studentFile = File ("$dir/student2.json"),
		subjectFile = File ("$dir/subjects2.json");

	set studentData(Map<String, dynamic> data) => studentFile.writeAsStringSync(
		jsonEncode(data)
	);

	Map<String, dynamic> get studentData => jsonDecode (
		studentFile.readAsStringSync()
	);

	Student student;

	set subjectData (Map<int, Map<String, dynamic>> subjects) => subjectFile.writeAsStringSync (
		jsonEncode (
			subjects.map (
				(int id, Map<String, dynamic> json) => MapEntry (
					id.toString(), 
					jsonEncode(json)
				)
			)
		)
	);

	Map<int, Map<String, dynamic>> get subjectData => jsonDecode(
		subjectFile.readAsStringSync()
	).map<int, Map<String, dynamic>> (
		(String id, dynamic json) => MapEntry (
			int.parse(id),
			jsonDecode(json) as Map<String, dynamic>
		)
	);

	Map<int, Subject> subjects;

	void deleteAll() {
		if (studentFile.existsSync())
			studentFile.deleteSync();
		if (subjectFile.existsSync())
			subjectFile.deleteSync();
	}

	bool get ready => studentFile.existsSync() && subjectFile.existsSync();
}
