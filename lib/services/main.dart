import "dart:async";

import "firestore.dart" as Firestore;
import "reader.dart";
import "preferences.dart";

import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart" show Subject, Day;
import "package:ramaz/data/note.dart" show Note;

void setToday(Reader reader) {
	final DateTime now = DateTime.now();
	final DateTime today = DateTime.utc(
		now.year, 
		now.month,
		now.day
	);
	reader.today = reader.calendar [today];
	if (reader.today?.name != null) Timer.periodic (
		Duration (minutes: 1),
		(Timer timer) {
			final int index = reader.today.period;
			if (index == null) return;
			reader.period = reader.student.getPeriods(reader.today) [index];
		}
	);
}

Future<void> initOnMain(Reader reader, Preferences prefs) async {
	reader.student = Student.fromJson(reader.studentData);
	reader.subjects = Subject.getSubjects(reader.subjectData);
	reader.notes = Note.fromList(reader.notesData);

	Map<DateTime, Day> calendar;
	if (prefs.shouldUpdateCalendar) {
		final Map<String, dynamic> month = (await Firestore.getMonth());
		calendar = Day.getCalendar(month);
		reader.calendarData = month;
		reader.calendar = calendar;
	} else reader.calendar = Day.getCalendar(reader.calendarData);
	setToday(reader);
}

Future<void> initOnLogin(Reader reader, Preferences prefs, String email) async {
	// retrieve raw data
	final Map<String, dynamic> studentData = await Firestore.getStudent(email);
	final Map<String, dynamic> month = await Firestore.getMonth();
	final List<Map<String, dynamic>> notesList = await Firestore.getNotes(email);

	// use the data to compute more data
	final Student student = Student.fromJson(studentData);
	final Map<String, Map<String, dynamic>> subjectData = 
		await Firestore.getClasses(student);
	final Map<String, Subject> subjects = Subject.getSubjects(subjectData);
	final Map<DateTime, Day> calendar = Day.getCalendar(month);
	final List<Note> notes = Note.fromList(notesList);

	// save the data
	reader.studentData = studentData;
	reader.student = student;
	reader.subjectData = subjectData;
	reader.subjects = subjects;
	reader.calendarData = month;
	reader.calendar = calendar;
	reader.notes = notes;
	reader.notesData = notesList;
	prefs.lastCalendarUpdate = DateTime.now();
	setToday(reader);
}
