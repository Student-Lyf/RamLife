import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/sections.dart";
import "package:firestore/services.dart";

Future<void> main() async {
	Args.initLogger("Indexing data...");

	final Map<String, String> courseNames = await Logger.logValue(
		"course names", () async => SectionReader.courseNames
	);

	final Map<String, String> sectionTeachers = await Logger.logValue(
		"section teachers", SectionReader.getSectionTeachers
	);

	final List<Section> sections = await Logger.logValue(
		"sections list", () => SectionLogic.getSections(
			courseNames: courseNames,
			sectionTeachers: sectionTeachers,
		)
	);

	Logger.info("Finished data indexing.");

	if (Args.upload) {
		await Logger.logProgress(
			"data upload", () => Firestore.uploadSections(sections)
		);
	} else {
		Logger.warning("Did not upload section data. Use the --upload flag.");
	}
	await app.delete();
	Logger.info("Processed ${sections.length} sections.");
}
