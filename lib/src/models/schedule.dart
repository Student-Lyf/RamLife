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
		notes.addListener(notesListener);
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
		notes.removeListener(notesListener);
		timer.cancel();
		super.dispose();
	}

	void notesListener() => updateNotes(true);

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
			onNewPeriod(true);
			timer?.cancel();
			timer = Timer.periodic(
				const Duration (minutes: 1),
				(Timer timer) => onNewPeriod()
			);
		}
	}

	void onNewPeriod([bool first = false]) {
		final DateTime newDate = DateTime.now();
		if (newDate.day != now.day) {
			// Day changed. Probably midnight
			now = newDate;
			return setToday();
		} else if (!today.school) {
			period = nextPeriod = periods = null;

			updateNotes(first);
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
			
			updateNotes(first);
			return;
		}

		// Only here if there is school right now
		period = periods [periodIndex];
		if (periodIndex < periods.length - 1)
			nextPeriod = periods [periodIndex + 1];

		updateNotes(first);
	}

	void updateNotes([bool scheduleNotifications = false]) {
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

		if (scheduleNotifications) {
			Future(scheduleNotes);
		}
		notifyListeners();
	}

	void scheduleNotes() async {
		await Notifications.cancelAll();
		final DateTime now = DateTime.now();
		if (!today.school || periodIndex == null || periods == null)
			return;
		for (int index = periodIndex; index < periods.length; index++) {
			final Period period = periods [index];
			for (final int noteIndex in notes.getNotes(
				period: period?.period,
				subject: subjects [period?.id]?.name,
				letter: today.letter,
			)) {
				final date = DateTime(
					now.year, 
					now.month, 
					now.day,
					period.time.start.hour,
					period.time.start.minutes,
				);
				print ("Scheduling note: ${notes.notes [noteIndex].message} for $date");
				await Notifications.scheduleNotification(
				date: DateTime(
					now.year, 
					now.month, 
					now.day,
					period.time.start.hour,
					period.time.start.minutes,
				),
				notification: Notification.note(
					title: "New note",
					message: notes.notes [noteIndex].message,
				)
			);}
		}
	}
}
