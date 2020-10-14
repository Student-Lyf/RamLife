import "dart:async" show Timer;

import "package:flutter/foundation.dart";

import "package:ramaz/services.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
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
	) {
		Models.reminders.addListener(remindersListener);
	}

	/// Does the main initialization work for the schedule model.
	/// 
	/// Should be called whenever there is new data for this model to work with.
	Future<void> init() async {
		student = Student.fromJson(await Services.instance.database.user);
		subjects = Subject.getSubjects(
			await Services.instance.database.getSections(student.getIds())
		);
		await initCalendar();
	}

	Future<void> initCalendar() async {
		calendar = Day.getCalendar(await Services.instance.database.calendar);
		setToday();
		notifyListeners();
	}

	@override 
	void dispose() {
		Models.reminders.removeListener(remindersListener);
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

		updateReminders(scheduleNotifications: first);  
		
		// no school today.
		if (!today.school) {  
			period = nextPeriod = periods = null;
			return;
		}

		// So we have school today...
		final int newIndex = today.period;


		// Maybe the day changed
		if (newIndex != null && newIndex == periodIndex) {
			// return notifyListeners();
			return;
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
		Models.reminders
			..currentReminders = Models.reminders.getReminders(
				period: period?.period,
				subject: subjects [period?.id]?.name,
				dayName: today.name,
			)
			..nextReminders = Models.reminders.getReminders(
				period: nextPeriod?.period,
				subject: subjects [nextPeriod?.id]?.name,
				dayName: today.name,
			);

		(Models.reminders.currentReminders ?? []).forEach(Models.reminders.markShown);

		if (scheduleNotifications) {
			Future(scheduleReminders);
		}
		notifyListeners();
	}

	/// Schedules notifications for today's reminders. 
	/// 
	/// Starting from the current period, schedules a notification for the period
	/// using [Notifications.scheduleNotification]
	Future<void> scheduleReminders() async {
		Services.instance.notifications.cancelAll();
		final DateTime now = DateTime.now();

		// No school today/right now
		if (!today.school || periodIndex == null || periods == null) {
			return;
		}

		// For all periods starting from periodIndex, schedule applicable reminders.
		for (int index = periodIndex; index < periods.length; index++) {
			final Period period = periods [index];
			for (final int reminderIndex in Models.reminders.getReminders(
				period: period?.period,
				subject: subjects [period?.id]?.name,
				dayName: today.name,
			)) {
				Services.instance.notifications.scheduleNotification(
					date: DateTime(
						now.year, 
						now.month, 
						now.day,
						period.time.start.hour,
						period.time.start.minutes,
					),
					notification: Notification.reminder(
						title: "New reminder",
						message: Models.reminders.reminders [reminderIndex].message,
					)
				);
			}
		}
	}

	bool isValidReminder(Reminder reminder) {
		switch(reminder.time.type) {
			case ReminderTimeType.period: 
				final PeriodReminderTime time = reminder.time;
				final Iterable<String> dayNames = student.schedule.keys;
				return dayNames.contains(time.dayName) 
					&& int.parse(time.period) <= student.schedule [time.dayName].length;
			case ReminderTimeType.subject: 
				final SubjectReminderTime time = reminder.time;
				return subjects.keys.contains(time.name);
			default: throw StateError("Reminder <$reminder> has invalid ReminderTime");
		}
	}
}
