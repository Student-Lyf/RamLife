import "package:flutter/foundation.dart";
import "dart:async" show Timer;

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/notes.dart";

import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart";

class Schedule with ChangeNotifier {
	static DateTime now = DateTime.now();

	final Student student;
	final Map<String, Subject> subjects;
	final Map<DateTime, Day> calendar;
	final Notes notes;

	Timer timer;
	Day today, currentDay;
	Period period, nextPeriod;
	List<Period> periods;

	int periodIndex;

	Schedule(
		Reader reader,
		{@required this.notes}
	) : 
		subjects = Subject.getSubjects(reader.subjectData),
		student = Student.fromJson(reader.studentData),
		calendar = Day.getCalendar(reader.calendarData) 
	{
		notes.addListener(updateNotes);
		setToday();
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
			notifyListeners();
			return;
		}

		// So we have school today...
		final int newIndex = today.period;
		if (newIndex != periodIndex) cleanNotes();
		periodIndex = newIndex;
		if (periodIndex == null) { // School ended
			period = nextPeriod = null;
			updateNotes();  // at least clear notes
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

	void cleanNotes() {
		// We cannot change the length of a list
		// while iterating over it
		final List<int> toRemove = [];
		for (final int index in notes.currentNotes) {
			if (!notes.notes [index].time.repeats) 
				toRemove.add (index);
		}
		for (final int index in toRemove) 
			notes.deleteNote(index);
	}

	void updateNotes() => notes
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
}