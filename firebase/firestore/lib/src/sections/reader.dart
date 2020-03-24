import "package:firestore/helpers.dart";

class SectionReader {
	static Future<Map<String, String>> get courseNames async => {
		await for (final Map<String, String> row in csvReader(DataFiles.courses))
			if (row ["SCHOOL_ID"] == "Upper")
				row ["ID"]: row ["FULL_NAME"]
	};

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
