import "dart:convert" show jsonDecode, jsonEncode;
import "dart:io" show File;

class Reader {
	final String dir;
	final File studentFile, subjectFile, calendarFile, notesFile, publicationsFile;
	Reader(this.dir) :
		// The files end with 2 because there seems to 
		// be some sort of ghost data in the original
		studentFile = File ("$dir/student2.json"),
		subjectFile = File ("$dir/subjects2.json"),
		calendarFile = File ("$dir/calendar.json"),
		publicationsFile = File ("$dir/publications.json"),
		notesFile = File ("$dir/notes.json");

	set studentData(Map<String, dynamic> data) => studentFile.writeAsStringSync(
		jsonEncode(data)
	);

	Map<String, dynamic> get studentData => jsonDecode (
		studentFile.readAsStringSync()
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

	Map<String, Map<String, dynamic>> get subjectData => jsonDecode(
		subjectFile.readAsStringSync()
	).map<String, Map<String, dynamic>> (
		(String id, dynamic json) => MapEntry (
			id,
			jsonDecode(json) as Map<String, dynamic>
		)
	);

	set calendarData (Map<String, dynamic> data) => calendarFile.writeAsStringSync(
		jsonEncode(data)
	);

	Map<String, dynamic> get calendarData => jsonDecode(
		calendarFile.readAsStringSync()
	);

	Map<String, dynamic> get notesData => Map<String, dynamic>.from(
		jsonDecode(
			notesFile.readAsStringSync()
		) ?? {}
	);

	set notesData(Map<String, dynamic> data) => notesFile.writeAsStringSync(
		jsonEncode(data ?? {})
	);

	List get publications => jsonDecode(
		publicationsFile.readAsStringSync()
	);

	set publications (List data) => publicationsFile.writeAsStringSync(
		jsonEncode(data)
	);

	void deleteAll() {
		if (studentFile.existsSync())
			studentFile.deleteSync();
		if (subjectFile.existsSync())
			subjectFile.deleteSync();
		if (calendarFile.existsSync())
			calendarFile.deleteSync();
		if (notesFile.existsSync())
			notesFile.deleteSync();
		if (publicationsFile.existsSync())
			publicationsFile.deleteSync();
	}

	bool get ready => (
		studentFile.existsSync() && subjectFile.existsSync() 
		&& notesFile.existsSync() && calendarFile.existsSync()
	);
}
