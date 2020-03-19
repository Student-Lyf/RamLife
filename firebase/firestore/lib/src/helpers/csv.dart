import "dir.dart";

/// An iterator over a CSV file. 
/// 
/// Assuming the first row is the header row, every iteration returns a 
/// `Map<String, String>`, where the keys are the headers and the values are 
/// the values of the current row. 
/// 
/// Since this function uses the async file reading methods, it returns [Stream]
/// instead of [Iterable]. To use it in a for loop, instead of using `for`, use
/// `await for` (and make the function async).
Stream<Map<String, String>> csvReader(String filename) async* {
	final File file = File(filename);
	final List<String> lines = await file.readAsLines();
	List<String> headers;
	for (int index = 0; index < lines.length; index++) {
		final List<String> contents = lines [index].split(",");
		if (index == 0) {
			headers = contents;
			continue;
		} else {
			yield Map.fromIterables(headers, contents);
		}
	}
}
