import "dart:collection/";

import "dir.dart";

// ignore: prefer_mixin
class CSVReader with IterableMixin<Map<String, dynamic>> {
	static final Directory dataDir = 
		Directory("${projectDir.parent.parent.path}data");

	static const String courses = "courses.csv";
	static const String faculty = "faculty.csv";
	static const String schedule = "schedule.csv";
	static const String section = "section.csv";
	static const String sectionSchedule = "section_schedule.csv";
	static const String students = "students.csv";

	final String filename;

	CSVReader(this.filename);

	@override
	Iterator<Map<String, dynamic>> get iterator =>
		CSVIterator(File("$dataDir/$filename"));
}

class CSVIterator extends Iterator<Map<String, dynamic>> {
	final File file;
	final List<String> lines;

	int index = -1;
	List<String> headers;

	CSVIterator(this.file) :
		lines = file.readAsLinesSync() 
	{
		if (lines.isEmpty) {
			throw RangeError("File is empty: ${file.path}");
		}
	}

	@override
	bool moveNext() {
		index++;
		if (index == lines.length) {
			return false;
		}
		final List<String> contents = lines [index].split(",");
		if (index == 0) {
			headers = contents;
			moveNext();
		}
		current = Map<String, dynamic>.fromIterables(headers, contents);
		return true;
	}

	@override 
	Map<String, dynamic> current; 
}
