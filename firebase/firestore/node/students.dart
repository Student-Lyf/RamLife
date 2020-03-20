import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/services.dart";
import "package:firestore/students.dart";


Future<void> main(List<String> args) async {
	final bool upload = args.contains("--upload");	
	logger
		..d("Upload: $upload.")
		..i("Indexing data...");

	final Map<String, List<String>> studentClasses = 
		await StudentReader.getStudentClasses();

	final Map<String, Student> students = await StudentReader.getStudents();

	final Map<String, List<Period>> periods = await StudentReader.getPeriods();

	final Map<String, String> homeroomLocations = StudentReader.homeroomLocations;

	final Map<String, Semesters> semesters = await StudentReader.getSemesters();

	final Map<Student, Map<Letter, List<Period>>> schedules = 
		StudentLogic.getSchedule(
			students: students,
			periods: periods,
			studentClasses: studentClasses,
			semesters: semesters,
		);

	final Map<Student, String> homerooms = StudentLogic.homerooms;

	final List<Student> studentsWithSchedules = 
		StudentLogic.getStudentsWithSchedules(
			schedules: schedules,
			homerooms: homerooms, 
			homeroomLocations: homeroomLocations,
		);

	logger.i("Finished data indexing.");

	if (upload) {
		logger.i("Uploading data...");
		await Firestore.upoadStudents(studentsWithSchedules);
		logger.i("Upload complete");
	}

	logger.i("Processed ${students.length} users.");
}