import "package:path_provider/path_provider.dart";
import "dart:convert" show jsonDecode, jsonEncode;
import "dart:io" show File;
import "dart:async" show Future;

import "package:ramaz/data/student.dart" show Student;

class Reader {
	String dir;
	File studentFile;

	Future<void> init() async {
		dir = (await getApplicationDocumentsDirectory()).path;
		studentFile = File ("$dir/student.json");
	}

	set student(Student student) => studentFile.writeAsStringSync (
		jsonEncode (
			student.toJson(),
			toEncodable: (dynamic letter) => letter.toString().split(".").last
		)
	);

	Student get student => Student.fromData(
		jsonDecode (
			studentFile.readAsStringSync()
		)
	);

	void deleteAll() {
		if (studentFile.existsSync())
			studentFile.deleteSync();
	}

	bool get ready => studentFile.existsSync();

}
