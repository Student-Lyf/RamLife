import "package:firestore/data.dart";

class SectionLogic {
	static String getCourseId(String sectionId) {
		final String result = sectionId.substring(0, sectionId.indexOf("-"));
		return result.startsWith("0") ? result.substring(1) : result;
	}

	static List<Section> getSections({
		@required Map<String, String> courseNames,
		@required Map<String, String> sectionTeachers,
	}) => [
		for (final MapEntry<String, String> entry in sectionTeachers.entries) 
			Section(
				id: entry.key,
				name: courseNames [getCourseId(entry.key)],
				teacher: entry.value,
			)
	];
}
