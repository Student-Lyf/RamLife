import "firestore.dart" as Firestore;
import "services.dart";

import "package:ramaz/data/student.dart";

DateTime now = DateTime.now();

Future<void> initOnMain(ServicesCollection services) async {
	if (services.prefs.shouldUpdateCalendar)
		services.reader.calendarData = await Firestore.getMonth();

	services.init();
}

Future<void> initOnLogin(ServicesCollection services, String email) async {
	// Save and initialize the student to get the subjects
	final Map<String, dynamic> studentData = await Firestore.getStudent(email);
	final Student student = Student.fromJson(studentData);		

	// save the data
	services.reader
		..studentData = studentData
		..subjectData = await Firestore.getClasses(student)
		..calendarData =  await Firestore.getMonth()
		..notesData = await Firestore.getNotes(email);

	services.prefs.lastCalendarUpdate = DateTime.now();

	services.init();
}
