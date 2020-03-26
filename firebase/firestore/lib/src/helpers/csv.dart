import "dir.dart";

/// An iterator over a CSV file with headers
/// 
/// Assuming the first row is the header row, every iteration returns a 
/// `Map<String, String>`, where the keys are the headers and the values are 
/// the values of the current row. The values are read from [csvReadLines].
/// 
/// Since this function uses the async file reading methods, it returns [Stream]
/// instead of [Iterable]. To use it in a for loop, instead of using `for`, use
/// `await for` (and make the function async).
Stream<Map<String, String>> csvReader(String filename) async* {
	// Needs to be broadcast so we can use [Stream.first]
	List<String> headers;
	await for(
		final List<String> contents in 
		csvReadLines(filename)
	) {
		if (headers == null) {
			headers = contents;
			continue;
		} 
		yield Map.fromIterables(headers, contents);
	}
}

/// Iterates over a CSV file and returns their contents.
/// 
/// Since this function uses the async file reading methods, it returns [Stream]
/// instead of [Iterable]. To use it in a for loop, instead of using `for`, use
/// `await for` (and make the function async).
Stream<List<String>> csvReadLines(String filename) async* {
	final File file = File(filename);
	final List<String> lines = await file.readAsLines();
	for (int index = 0; index < lines.length; index++) {
		List<String> contents = lines[index].split(",");

		// If a comma is inside quotes, join them together
		int startIndex, endIndex;
		for (int rowIndex = 0; rowIndex < contents.length; rowIndex++) {
			if (contents [rowIndex].startsWith('"')) {
				startIndex = rowIndex;
			}
			if (contents [rowIndex].endsWith('"')) {
				endIndex = rowIndex + 1;
				break;
			}
		}

		assert(
			(startIndex == null) == (endIndex == null), 
			"Cannot parse CSV line $index in $filename: $contents"
		);

		if (startIndex != null && endIndex != null) {
			contents = [
				...contents.sublist(0, startIndex),
				contents.sublist(startIndex, endIndex).join(" "),
				...contents.sublist(endIndex)
			];
		}
		yield contents;
	}
}
