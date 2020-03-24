import "package:node_interop/node.dart";  // provides args

import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/services.dart";
import "package:firestore/students.dart";

Future<void> main() async {
	final List args = process.argv.sublist(2);  // needed for Node.js
	final bool upload = args.contains("--upload");	
	final bool verbose = {"--verbose", "-v"}.any(args.contains);
	if (verbose) {
		Logger.level = LogLevel.verbose;
	}
	Logger.debug("Upload: $upload.");
	Logger.info("Indexing data...");

	final Map<String, List<String>> studentClasses = 
		await StudentReader.getStudentClasses();

	final Map<String, Student> students = await StudentReader.getStudents();

	final Map<String, List<Period>> periods = await StudentReader.getPeriods();

	// Early 2020 data did not contain homerooms...
	// final Map<String, String> homeroomLocations = 
		// StudentReader.homeroomLocations;
	final Map<String, String> homeroomLocations = DefaultMap((_) => "Unavailable");
	Logger.debug("Homeroom locations: $homeroomLocations");

	final Map<String, Semesters> semesters = await StudentReader.getSemesters();

	final Map<Student, Map<Letter, List<Period>>> schedules = 
		StudentLogic.getSchedule(
			students: students,
			periods: periods,
			studentClasses: studentClasses,
			semesters: semesters,
		);

	final Map<Student, String> homerooms = StudentLogic.homerooms;
	Logger.debug("Homerooms: $homerooms");

	final List<Student> studentsWithSchedules = 
		StudentLogic.getStudentsWithSchedules(
			schedules: schedules,
			homerooms: homerooms, 
			homeroomLocations: homeroomLocations,
		);

	Logger.info("Finished data indexing.");

	if (upload) {
		Logger.info("Uploading data...");
		await Firestore.upoadStudents(studentsWithSchedules);
		Logger.info("Upload complete");
	}

	Logger.info("Processed ${students.length} users.");
}