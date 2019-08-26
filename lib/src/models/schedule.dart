import "package:flutter/foundation.dart";
import "dart:async" show Timer;

import "notes.dart";

import "package:ramaz/services.dart";
import "package:ramaz/data.dart";

class Schedule with ChangeNotifier {
	static DateTime now = DateTime.now();

	final Notes notes;

	Student student;
	Map<String, Subject> subjects;
	Map<DateTime, Day> calendar;

	Timer timer;
	Day today, currentDay;
	Period period, nextPeriod;
	List<Period> periods;

	int periodIndex;

	Schedule(
		Reader reader,
		{@required this.notes}
	) {
		setup(reader);
		notes.addListener(updateNotes);
	}

	void setup(Reader reader) {
		subjects = Subject.getSubjects(reader.subjectData);
		student = Student.fromJson(reader.studentData);
		calendar = Day.getCalendar(reader.calendarData);
		setToday();
		notifyListeners();
	}

	@override 
	void dispose() {
		timer.cancel();
		super.dispose();
	}

	Subject get subject => subjects [period?.id];
	bool get hasSchool => today.school;

	void setToday() {
		// Get rid of the time
		final DateTime currentDate = DateTime.utc(
			now.year, 
			now.month,
			now.day
		); 
		
		today = currentDay = calendar [currentDate];
		if (today.school) {
			periods = student.getPeriods(today);
			onNewPeriod();
			timer?.cancel();
			timer = Timer.periodic(
				const Duration (minutes: 1),
				(Timer timer) => onNewPeriod()
			);
		}
	}

	void onNewPeriod() {
		final DateTime newDate = DateTime.now();
		if (newDate.day != now.day) {
			// Day changed. Probably midnight
			now = newDate;
			return setToday();
		} else if (!today.school) {
			period = nextPeriod = periods = null;

			updateNotes();
			notifyListeners();
			return;
		}

		// So we have school today...
		final int newIndex = today.period;
		if (newIndex != null && newIndex == periodIndex) 
			// Maybe the day changed
			return notifyListeners();
		periodIndex = newIndex;
		if (periodIndex == null) { // School ended
			period = nextPeriod = null;
			
			updateNotes();
			notifyListeners();
			return;
		}

		// Only here if there is school right now
		period = periods [periodIndex];
		if (periodIndex < periods.length - 1)
			nextPeriod = periods [periodIndex + 1];

		updateNotes();
		notifyListeners();
	}

	void updateNotes() {
		notes
			..currentNotes = notes.getNotes(
				period: period?.period,
				subject: subjects [period?.id]?.name,
				letter: today.letter,
			)
			..nextNotes = notes.getNotes(
				period: nextPeriod?.period,
				subject: subjects [nextPeriod?.id]?.name,
				letter: today.letter,
			);

		for (final int index in notes.currentNotes ?? [])
			notes.shown = index;

		notes.cleanNotes();
	}
}