import "package:node_interop/node.dart";  // provides args

import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/sections.dart";
import "package:firestore/services.dart";

Future<void> main() async {
	final List args = process.argv.sublist(2);  // needed for Node.js
	final bool upload = args.contains("--upload");	
	final bool verbose = {"--verbose", "-v"}.any(args.contains);
	if (verbose) {
		Logger.level = LogLevel.verbose;
	}
	Logger.debug("Upload: $upload.");
	Logger.info("Indexing data...");

	final Map<String, String> courseNames = await SectionReader.courseNames;

	final Map<String, String> sectionTeachers = 
		await SectionReader.getSectionTeachers();

	final List<Section> sections = SectionLogic.getSections(
		courseNames: courseNames,
		sectionTeachers: sectionTeachers,
	);

	Logger.info("Finished data indexing.");

	if (upload) {
		Logger.info("Uploading data...");
		await Firestore.uploadSections(sections);
		Logger.info("Upload complete");
	}

	Logger.info("Processed ${sections.length} sections.");
}
