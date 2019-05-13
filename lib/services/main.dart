import "firestore.dart" as Firestore;
import "reader.dart";
import "preferences.dart";

import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart" show Subject, Day;

void initOnMain(Reader reader, Preferences prefs) async {
	reader.student = Student.fromData(reader.studentData);
	reader.subjects = Subject.getSubjects(reader.subjectData);
	if (prefs.shouldUpdateCalendar) {
		final Map<String, dynamic> month = await Firestore.getMonth();
		final Map<DateTime, Day> calendar = Day.getCalendar(month);
		reader.calendarData = month;
		reader.calendar = calendar;
	}
}

void initOnLogin(Reader reader, Preferences prefs, String username) async {
	// retrieve raw data
	final Map<String, dynamic> studentData = await Firestore.getStudent(username);
	final Map<String, dynamic> month = await Firestore.getMonth();

	// use the data to comput more data
	final Student student = Student.fromData(studentData);
	final Map<int, Map<String, dynamic>> subjectData = 
		await Firestore.getClasses(student);
	final Map<int, Subject> subjects = Subject.getSubjects(subjectData);
	final Map<DateTime, Day> calendar = Day.getCalendar(month);

	// save the data
	reader.studentData = studentData;
	reader.student = student;
	reader.subjectData = subjectData;
	reader.subjects = subjects;
	reader.calendarData = month;
	reader.calendar = calendar;
	prefs.lastCalendarUpdate = DateTime.now();
}
