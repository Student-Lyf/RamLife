import "package:node_interop/node.dart";  // provides args

import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/sections.dart";
import "package:firestore/services.dart";

Future<void> main() async {
	final List args = process.argv.sublist(2);  // needed for Node.js
	final bool upload = args.contains("--upload");	
	final bool verbose = {"--verbose", "-v"}.any(args.contains);
	final bool debug = {"--debug", "-d"}.any(args.contains);
	if (debug) {
		Logger.level = LogLevel.debug;
	} else if (verbose) {
		Logger.level = LogLevel.verbose;
	}
	Logger.debug("Upload: $upload.");
	Logger.info("Indexing data...");

	Logger.debug("Getting course names");
	final Map<String, String> courseNames = await SectionReader.courseNames;
	Logger.verbose("Names: $courseNames.");

	Logger.debug("Getting teachers for each section");
	final Map<String, String> sectionTeachers = 
		await SectionReader.getSectionTeachers();
	Logger.verbose("Teachers: $sectionTeachers.");

	Logger.debug("Building list of sections");
	final List<Section> sections = SectionLogic.getSections(
		courseNames: courseNames,
		sectionTeachers: sectionTeachers,
	);
	Logger.verbose("Sections: $sections");

	Logger.info("Finished data indexing.");

	if (upload) {
		Logger.info("Uploading data...");
		await Firestore.uploadSections(sections);
		Logger.info("Upload complete");
	}

	Logger.info("Processed ${sections.length} sections.");
}
