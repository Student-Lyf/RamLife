import "dart:async";

import "firestore.dart" as Firestore;
import "reader.dart";
import "preferences.dart";
import "services.dart";
import "notes.dart";

import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/note.dart" show Note;

DateTime now = DateTime.now();

void onNewPeriod(ServicesCollection services) {
	final Reader reader = services.reader;
	final DateTime newDate = DateTime.now();
	if (newDate.day != now.day) {
		now = newDate;
		return setToday(services);
	}

	if (!reader.today.school) {
		reader.period = null; 
		reader.nextPeriod = null;
		return;
	}

	final int index = reader.today.period;
	reader.periodIndex = index;
	if (index == null) {
		reader.period = null;
		return;
	}

	reader.period = reader.periods [index];
	Period nextPeriod;
	if (index < reader.periods.length - 1) 
		nextPeriod = reader.periods [index + 1];
	reader.nextPeriod = nextPeriod;

	final Notes notes = services.notes;
	notes.hasNote = Note.getNotes(
		notes: notes.notes,
		subject: reader.subjects [reader.period?.id],
		period: reader.nextPeriod?.period,
		letter: reader.today.letter,
	).isNotEmpty;
}

void setToday(ServicesCollection services) {
	final Reader reader = services.reader;
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
		onNewPeriod(services);
		Timer.periodic (
			Duration (minutes: 1),
			(Timer timer) => onNewPeriod(services),
		);
	}
}

Future<void> initOnMain(ServicesCollection services) async {
	services.init();
	final Reader reader = services.reader;
	final Preferences prefs = services.prefs;
	reader.student = Student.fromJson(reader.studentData);
	reader.subjects = Subject.getSubjects(reader.subjectData);

	Map<DateTime, Day> calendar;
	if (prefs.shouldUpdateCalendar) {
		final Map<String, dynamic> month = (await Firestore.getMonth());
		calendar = Day.getCalendar(month);
		reader.calendarData = month;
		reader.calendar = calendar;
	} else reader.calendar = Day.getCalendar(reader.calendarData);
	setToday(services);
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

	final Reader reader = services.reader;
	// save the data
	reader.studentData = studentData;
	reader.student = student;
	reader.subjectData = subjectData;
	reader.subjects = subjects;
	reader.calendarData = month;
	reader.calendar = calendar;
	reader.notesData = List<Map<String, dynamic>>.from(
		notesList.map(
			(dynamic json) => Map<String, dynamic>.from(json)
		).toList()
	);
	services.prefs.lastCalendarUpdate = DateTime.now();
	setToday(services);
}
