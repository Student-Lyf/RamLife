import "package:firestore/helpers.dart";

/// A collection of functions to read course data.
/// 
/// No function in this class actually performs logic on said data, just returns
/// it. This helps keep the program modular, by separating the data sources from
/// the data indexing.
class SectionReader {
	/// Maps course IDs to their respective names.
	static Future<Map<String, String>> get courseNames async => {
		await for (final Map<String, String> row in csvReader(DataFiles.courses))
			if (row ["SCHOOL_ID"] == "Upper")
				row ["ID"]: row ["FULL_NAME"]
	};

	/// Maps section IDs to their respective teachers. 
	/// 
	/// If [id] is true, the values are the faculty IDs. Otherwise, the values are
	/// the teachers' full names.
	static Future<Map<String, String>> getSectionTeachers({
		bool id = false
	}) async {
		final Map<String, String> result = {};
		await for(final Map<String, String> row in csvReader(DataFiles.section)) {
			final String teacher = row [id ? "FACULTY_ID" : "FACULTY_FULL_NAME"];
			if (row ["SCHOOL_ID"] != "Upper" || teacher.isEmpty) {
				continue;
			}
			result [row ["SECTION_ID"]] = teacher;
		}
		return result;
	} 
}
