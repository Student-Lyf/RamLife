import "dart:async" show Timer;
import "package:flutter/foundation.dart";

import "package:ramaz/services.dart";
import "package:ramaz/data.dart";

import "reminders.dart";

/// A data model for the user's schedule.
// ignore: prefer_mixin
class Schedule with ChangeNotifier {
	/// The current date.
	/// 
	/// This helps track when the day has changed. 
	static DateTime now = DateTime.now();

	/// How often to refresh the schedule.
	static const timerInterval = Duration (minutes: 1);

	/// The reminders data model.
	/// 
	/// This is used to schedule reminders based on the next and 
	/// upcoming periods, as well as react to changes in user reminders. 
	/// See [updateReminders] and [scheduleReminders].
	final Reminders reminders;

	/// The student object for the user. 
	Student student;

	/// The subjects this user has. 
	Map<String, Subject> subjects;

	/// The calendar for the month.
	List<List<Day>> calendar;

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
		{@required this.reminders}
	) {
		setup(reader);
		reminders.addListener(remindersListener);
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
		reminders.removeListener(remindersListener);
		timer.cancel();
		super.dispose();
	}

	/// A callback that runs whenever the reminders data model changes.
	/// 
	/// See [updateReminders].
	void remindersListener() => updateReminders(scheduleNotifications: true);

	/// The current subject.
	Subject get subject => subjects [period?.id];

	/// The next subject.
	Subject get nextSubject => subjects [nextPeriod?.id];

	/// Whether there is school today.
	bool get hasSchool => today.school;

	/// Changes the current day. 
	/// 
	/// If there is school today, then schedules the time to update every period.
	/// See [onNewPeriod].
	/// 
	/// Only to be called when the day actually changes. 
	void setToday() {
		// initialize today
		today = Day.getDate(calendar, now);
		timer?.cancel();
		if (today.school) {
			// initialize periods.
			periods = student.getPeriods(today);
			// initialize the current period.
			onNewPeriod(first: true);
			// initialize the timer. See comments for [timer].
			timer = Timer.periodic(
				timerInterval,
				(Timer timer) => onNewPeriod()
			);
		}
	}

	/// Updates the current period.
	void onNewPeriod({bool first = false}) {
		final DateTime newDate = DateTime.now();

		// Day changed. Probably midnight.
		if (newDate.day != now.day) {
			now = newDate;
			return setToday();
		}

		// no school today.
		if (!today.school) {  
			period = nextPeriod = periods = null;
			return;
		}

		// So we have school today...
		final int newIndex = today.period;

		// Maybe the day changed
		if (newIndex != null && newIndex == periodIndex) {
			return notifyListeners();
		}

		// period changed since last checked.
		periodIndex = newIndex;

		// School ended
		if (periodIndex == null) { 
			period = nextPeriod = null;
			return;
		}

		// Period changed and there is still school.
		period = periods [periodIndex];
		nextPeriod = periodIndex < periods.length - 1 
			? periods [periodIndex + 1] 
			: null;

		// first => schedule notifications.
		updateReminders(scheduleNotifications: first);  
	}

	/// Updates the reminders given the current period.
	/// 
	/// Is responsible for updating [Reminders.currentReminders], 
	/// [Reminders.nextReminders] and calling [Reminders.markShown]. Will also
	/// schedule notifications if that has not been done yet today or as a 
	/// response to changed reminders. See [scheduleReminders] for more details
	/// on scheduling notifications.
	void updateReminders({bool scheduleNotifications = false}) {
		reminders
			..currentReminders = reminders.getReminders(
				period: period?.period,
				subject: subjects [period?.id]?.name,
				letter: today.letter,
			)
			..nextReminders = reminders.getReminders(
				period: nextPeriod?.period,
				subject: subjects [nextPeriod?.id]?.name,
				letter: today.letter,
			);

		(reminders.currentReminders ?? []).forEach(reminders.markShown);

		if (scheduleNotifications) {
			Future(scheduleReminders);
		}
		notifyListeners();
	}

	/// Schedules notifications for today's reminders. 
	/// 
	/// Starting from the current period, schedules a notification for the period
	/// using [Notifications.scheduleNotification].
	Future<void> scheduleReminders() async {
		Notifications.cancelAll();
		final DateTime now = DateTime.now();

		// No school today/right now
		if (!today.school || periodIndex == null || periods == null) {
			return;
		}

		// For all periods starting from periodIndex, schedule applicable reminders.
		for (int index = periodIndex; index < periods.length; index++) {
			final Period period = periods [index];
			for (final int reminderIndex in reminders.getReminders(
				period: period?.period,
				subject: subjects [period?.id]?.name,
				letter: today.letter,
			)) {
				Notifications.scheduleNotification(
					date: DateTime(
						now.year, 
						now.month, 
						now.day,
						period.time.start.hour,
						period.time.start.minutes,
					),
					notification: Notification.reminder(
						title: "New reminder",
						message: reminders.reminders [reminderIndex].message,
					)
				);
			}
		}
	}
}
