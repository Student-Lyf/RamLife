import "package:firestore/data.dart";

import "package:firestore/faculty.dart";
import "reader.dart";  // for doc comments

/// A collection of functions to index course data. 
/// 
/// No function in this class reads data from the data files, just works logic
/// on them. This helps keep the program modular, by separating the data sources
/// from the data indexing.
class SectionLogic {
	/// Converts a section ID to a course ID.
	static String getCourseId(String sectionId) {
		final String result = sectionId.substring(0, sectionId.indexOf("-"));
		return result.startsWith("0") ? result.substring(1) : result;
	}

	/// Builds a list of [Section] objects.
	/// 
	/// This function works by taking several arguments: 
	/// 
	/// - courseNames, from [SectionReader.courseNames]
	/// - sectionTeachers, from [SectionReader.getSectionFacultyIds]
	/// - facultyNames, from [FacultyReader.getFaculty]
	/// 
	/// These are kept as parameters instead of calling the functions by itself
	/// in order to keep the data and logic layers separate. 
	static List<Section> getSections({
		@required Map<String, String> courseNames,
		@required Map<String, String> sectionTeachers,
		@required Map<String, User> facultyNames,
		@required Map<String, String> zoomLinks,
	}) => [
		for (final MapEntry<String, String> entry in sectionTeachers.entries) 
			Section(
				id: entry.key,
				name: courseNames [getCourseId(entry.key)],
				teacher: facultyNames [entry.value].name,
				zoomLink: zoomLinks [entry.key],
			)
	];
}
