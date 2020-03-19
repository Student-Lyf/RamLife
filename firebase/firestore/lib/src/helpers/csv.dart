import "dart:collection/";

import "dir.dart";

// ignore: prefer_mixin
class CSVReader with IterableMixin<Map<String, String>> {
	final String filename;

	CSVReader(this.filename);

	@override
	Iterator<Map<String, String>> get iterator =>
		CSVIterator(File("${DataFiles.dataDir}/$filename"));
}

class CSVIterator extends Iterator<Map<String, String>> {
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
		current = Map<String, String>.fromIterables(headers, contents);
		return true;
	}

	@override 
	Map<String, String> current; 
}
