import "dart:async";

import "firestore.dart" as Firestore;
import "reader.dart";
import "preferences.dart";

import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart" show Subject, Day;

void setToday(Reader reader) {
	final DateTime now = DateTime.now();
	final DateTime today = DateTime.utc(
		now.year, 
		now.month,
		now.day
	);
	reader.today = reader.calendar [today];
	if (reader.today != null && reader.today.letter != null)
		Timer.periodic (
			Duration (minutes: 1),
			(Timer timer) => reader.period = 
				reader.student.getPeriods(reader.today) [reader.today.period]
		);
}

Future<void> initOnMain(Reader reader, Preferences prefs) async {
	reader.student = Student.fromData(reader.studentData);
	reader.subjects = Subject.getSubjects(reader.subjectData);
	Map<DateTime, Day> calendar;
	if (prefs.shouldUpdateCalendar) {
		final Map<String, dynamic> month = (await Firestore.getMonth());
		calendar = Day.getCalendar(month);
		reader.calendarData = month;
		reader.calendar = calendar;
	} else reader.calendar = Day.getCalendar(reader.calendarData);
	setToday(reader);
}

Future<void> initOnLogin(Reader reader, Preferences prefs, String username) async {
	// retrieve raw data
	final Map<String, dynamic> studentData = await Firestore.getStudent(username);
	final Map<String, dynamic> month = await Firestore.getMonth();

	// use the data to compute more data
	final Student student = Student.fromData(studentData);
	final Map<String, Map<String, dynamic>> subjectData = 
		await Firestore.getClasses(student);
	final Map<String, Subject> subjects = Subject.getSubjects(subjectData);
	final Map<DateTime, Day> calendar = Day.getCalendar(month);

	// save the data
	reader.studentData = studentData;
	reader.student = student;
	reader.subjectData = subjectData;
	reader.subjects = subjects;
	reader.calendarData = month;
	reader.calendar = calendar;
	prefs.lastCalendarUpdate = DateTime.now();
	setToday(reader);
}
