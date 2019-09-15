import "package:flutter/foundation.dart";
import "dart:async" show Timer;

import "notes.dart";

import "package:ramaz/services.dart";
import "package:ramaz/data.dart";

/// A data model for the user's schedule.
class Schedule with ChangeNotifier {
	/// The current date.
	/// 
	/// This helps track when the day has changed. 
	static DateTime now = DateTime.now();

	/// How often to refresh the schedule.
	static const timerInterval = Duration (minutes: 1);

	/// The notes data model.
	/// 
	/// This is used to schedule notes based on the next and 
	/// upcoming periods. See [updateNotes] and [scheduleNotes].
	final Notes notes;

	/// The student object for the user. 
	Student student;

	/// The subjects this user has. 
	Map<String, Subject> subjects;

	/// The calendar for the month.
	Map<DateTime, Day> calendar;

	/// A timer that updates the period. 
	/// 
	/// This timer fires once every [timerInterval], and calls [onNewPeriod]
	/// when it does. 
	Timer timer;

	/// The [Day] that represents today.
	Day today;

	/// The current period. 
	Period period;

	/// The next period.
	Period nextPeriod;

	/// A list of today's periods.
	List<Period> periods;

	/// The index that represents [period]'s location in [periods].
	int periodIndex;

	/// Initializes the schedule model.
	Schedule(
		Reader reader,
		{@required this.notes}
	) {
		setup(reader);
		notes.addListener(notesListener);
	}

	/// Does the main initialization work for the schedule model.
	/// 
	/// Should be called whenever there is new data for this model to work with.
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

	/// A callback that runs whenever the notes data model changes.
	/// 
	/// See [updateNotes].
	void notesListener() => updateNotes(true);

	/// The current subject.
	Subject get subject => subjects [period?.id];

	/// Whether there is school today.
	bool get hasSchool => today.school;

	/// Changes the current day. 
	/// 
	/// If there is school today, then schedules the time to update every period.
	/// See [onNewPeriod].
	/// 
	/// Only to be called when the day actually changes. 
	void setToday() {
		// Get rid of the time
		final DateTime currentDate = DateTime.utc(
			now.year, 
			now.month,
			now.day
		); 
		
		// initialize today
		today = calendar [currentDate];
		timer?.cancel();
		if (today.school) {
			// initialize periods.
			periods = student.getPeriods(today);
			// initialize the current period.
			onNewPeriod(true);
			// initialize the timer. See comments for [timer].
			timer = Timer.periodic(
				timerInterval,
				(Timer timer) => onNewPeriod()
			);
		}
	}

	/// Updates the current period.
	void onNewPeriod([bool first = false]) {
		final DateTime newDate = DateTime.now();

		// Day changed. Probably midnight.
		if (newDate.day != now.day) {
			now = newDate;
			return setToday();
		}

		// first => schedule notifications.
		updateNotes(first);  

		// no school today.
		if (!today.school) {  
			period = nextPeriod = periods = null;
			return;
		}

		// So we have school today...
		final int newIndex = today.period;

		// Maybe the day changed
		if (newIndex != null && newIndex == periodIndex) 
			return notifyListeners();

		// period changed since last checked.
		periodIndex = newIndex;

		// School ended
		if (periodIndex == null) { 
			period = nextPeriod = null;
			return;
		}

		// Period changed and there is still school.
		period = periods [periodIndex];
		if (periodIndex < periods.length - 1)
			nextPeriod = periods [periodIndex + 1];
	}

	/// Updates the notes given the current period.
	/// 
	/// Is responsible for updating [Notes.currentNotes], [Notes.nextNotes], 
	/// and calling [Notes.markShown]. Will also schedule notifications if that
	/// has not been done yet today or as a response to changed notes. See 
	/// [scheduleNotes] for more details on scheduling notifications.
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
			notes.markShown(index);

		if (scheduleNotifications) {
			Future(scheduleNotes);
		}
		notifyListeners();
	}

	/// Schedules notifications for today's notes. 
	/// 
	/// Starting from the current period, schedules a notification for the period
	/// using [Notifications.scheduleNotification].
	void scheduleNotes() async {
		await Notifications.cancelAll();
		final DateTime now = DateTime.now();

		// No school today/right now
		if (!today.school || periodIndex == null || periods == null)
			return;

		// For all periods starting from periodIndex, schedule applicable notes.
		for (int index = periodIndex; index < periods.length; index++) {
			final Period period = periods [index];
			for (final int noteIndex in notes.getNotes(
				period: period?.period,
				subject: subjects [period?.id]?.name,
				letter: today.letter,
			)) await Notifications.scheduleNotification(
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
			);
		}
	}
}
