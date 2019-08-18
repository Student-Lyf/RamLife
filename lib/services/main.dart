import "dart:async";

import "firestore.dart" as Firestore;
import "reader.dart";
import "preferences.dart";
import "services.dart";

import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/note.dart" show Note;

DateTime now = DateTime.now();

void onNewPeriod(Reader reader) {
	final DateTime newDate = DateTime.now();
	if (newDate.day != now.day) {
		now = newDate;
		return setToday(reader);
	}

	if (!reader.today.school) {
		reader.period = null; 
		reader.nextPeriod = null;
		return;
	}

	final int index = reader.today.period;
	reader.periodIndex = index;
	if (index != null) {
		reader.period = reader.periods [index];
		Period nextPeriod;
		if (index < reader.periods.length - 1) 
			nextPeriod = reader.periods [index + 1];
		reader.nextPeriod = nextPeriod;

		reader.hasNote = Note.getNotes(
			notes: reader.notes,
			subject: reader.subjects [reader.period?.id],
			period: reader.nextPeriod?.period,
			letter: reader.today.letter,
		).isNotEmpty;
	} else reader.period = null;
}

void setToday(Reader reader) {
	final DateTime today = DateTime.utc(
		now.year, 
		now.month,
		now.day
	);
	Day schoolDay = reader.calendar [today];
	reader.today = schoolDay;
	reader.currentDay = schoolDay;
	if (schoolDay.school) {
		reader.periods = reader.student.getPeriods(schoolDay);
		onNewPeriod(reader);
		Timer.periodic (
			Duration (minutes: 1),
			(Timer timer) => onNewPeriod(reader),
		);
	}
}

Future<void> initOnMain(ServicesCollection services) async {
	final Reader reader = services.reader;
	final Preferences prefs = services.prefs;
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

Future<void> initOnLogin(ServicesCollection services, String email) async {
	// retrieve raw data
	final Map<String, dynamic> studentData = await Firestore.getStudent(email);
	final Map<String, dynamic> month = await Firestore.getMonth();
	final List notesList = await Firestore.getNotes(email);

	// use the data to compute more data
	final Student student = Student.fromJson(studentData);
	final Map<String, Map<String, dynamic>> subjectData = 
		await Firestore.getClasses(student);
	final Map<String, Subject> subjects = Subject.getSubjects(subjectData);
	final Map<DateTime, Day> calendar = Day.getCalendar(month);
	final List<Note> notes = Note.fromList(notesList);

	final Reader reader = services.reader;
	// save the data
	reader.studentData = studentData;
	reader.student = student;
	reader.subjectData = subjectData;
	reader.subjects = subjects;
	reader.calendarData = month;
	reader.calendar = calendar;
	reader.notes = notes;
	reader.notesData = notes;
	services.prefs.lastCalendarUpdate = DateTime.now();
	setToday(reader);
}
