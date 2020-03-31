import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/sections.dart";
import "package:firestore/services.dart";
import "package:firestore/zoom.dart";

Future<void> main() async {
	Args.initLogger("Indexing Zoom schedules");

	// I know, I know
	final Map<Letter, List<List<List<String>>>> zoomSchedules = 
		await Logger.logValue(
			"zoom schedules", ZoomReader.getSchedule,
		);

	final Map<String, List<Period>> periods = await Logger.logValue(
		"section periods", () => ZoomLogic.getPeriods(zoomSchedules)
	);

	final Map<String, String> sectionTeachers = await Logger.logValue(
		"section names (for verification)", 
		() => SectionReader.getSectionTeachers(id: true)
	);

	Logger.verbose("verifying section IDs");
	ZoomLogic.verifySection(
		periods: periods,
		sectionTeachers: sectionTeachers,
	);

	Logger.info("Getting student schedules");
	final List<User> students = await ZoomLogic.getStudents(periods);

	Logger.info("Getting faculty schedules");
	final List<User> faculty = await ZoomLogic.getFaculty(
		periods: periods,
		sectionTeachers: sectionTeachers,
	);

	if (Args.upload) {
		await Logger.logProgress(
			"student schedule upload", () => Firestore.upoadStudents(students)
		);
		await Logger.logProgress(
			"faculty schedule upload", () => Firestore.upoadStudents(faculty)
		);
	}

	await app.delete();
	Logger.info("Zoom schedules indexed");
	Logger.info(
		"Processed ${students.length} students and ${faculty.length} faculty"
	);
}
