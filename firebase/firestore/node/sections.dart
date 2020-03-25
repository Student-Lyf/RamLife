import "package:node_interop/node.dart";  // provides args

import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/sections.dart";
import "package:firestore/services.dart";

Future<void> main() async {
	final List args = process.argv.sublist(2);  // needed for Node.js
	AnsiColor.supportsColor = !args.contains("--no-color");
	final bool upload = args.contains("--upload");	
	final bool verbose = {"--verbose", "-v"}.any(args.contains);
	final bool debug = {"--debug", "-d"}.any(args.contains);
	if (debug) {
		Logger.level = LogLevel.debug;
	} else if (verbose) {
		Logger.level = LogLevel.verbose;
	}
	Logger.debug("upload", upload);
	Logger.info("Indexing data...");


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

	if (upload) {
		await Logger.logProgress(
			"data upload", () => Firestore.uploadSections(sections)
		);
	}

	Logger.info("Processed ${sections.length} sections.");
}
