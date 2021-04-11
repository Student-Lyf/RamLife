import "dart:async" show Timer;

import "package:ramaz/services.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

import "model.dart";
import "reminders.dart";

/// A data model for the user's schedule.
class Schedule extends Model {
	/// The current date.
	/// 
	/// This helps track when the day has changed. 
	static DateTime now = DateTime.now();

	/// How often to refresh the schedule.
	static const timerInterval = Duration (minutes: 1);

	/// The current user. 
	late User user;

	/// The subjects this user has. 
	late Map<String, Subject> subjects;

	/// The calendar for the month.
	late List<List<Day?>> calendar;

	/// A timer that updates the period. 
	/// 
	/// This timer fires once every [timerInterval], and calls [onNewPeriod]
	/// when it does. 
	Timer? timer;

	/// The [Day] that represents today.
	Day? today;

	/// The current period. 
	Period? period;

	/// The next period.
	Period? nextPeriod;

	/// A list of today's periods.
	List<Period>? periods;

	/// The index that represents [period]'s location in [periods].
	int? periodIndex;

	/// The reminders data model. 
	late Reminders reminders;

	@override
	Future<void> init() async {
		reminders = Models.instance.reminders
			..addListener(remindersListener);
		user = Models.instance.user.data;
		subjects = Models.instance.user.subjects;
		await initCalendar();
	}

	/// Initializes the calendar. 
	Future<void> initCalendar() async {
		calendar = Day.getCalendar(await Services.instance.database.calendar);
		setToday();
		notifyListeners();
	}

	@override 
	void dispose() {
		Models.instance.reminders.removeListener(remindersListener);
		timer?.cancel();
		super.dispose();
	}

	/// A callback that runs whenever the reminders data model changes.
	/// 
	/// See [updateReminders].
	void remindersListener() => updateReminders(scheduleNotifications: true);

	/// The current subject.
	Subject? get subject => subjects [period?.id];

	/// The next subject.
	Subject? get nextSubject => subjects [nextPeriod?.id];

	/// Whether there is school today.
	bool get hasSchool => today != null;

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
		if (hasSchool) {
			// initialize periods.
			periods = user.getPeriods(today!);
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
		if (!hasSchool) {  
			period = nextPeriod = periods = null;
			return;
		}

		// So we have school today...
		final int? newIndex = today?.period;

		// Maybe the day changed
		if (newIndex != null && newIndex == periodIndex) {
			return;
		}

		// period changed since last checked.
		periodIndex = newIndex;
		updateReminders(scheduleNotifications: first);  

		// School ended
		if (newIndex == null) { 
			period = nextPeriod = null;
			return;
		}

		// Period changed and there is still school.
		period = periods! [newIndex];
		nextPeriod = newIndex < periods!.length - 1 
			? periods! [newIndex + 1] 
			: null;
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
				dayName: today?.name,
			)
			..nextReminders = reminders.getReminders(
				period: nextPeriod?.period,
				subject: subjects [nextPeriod?.id]?.name,
				dayName: today?.name,
			);

		reminders.currentReminders.forEach(reminders.markShown);

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
		if (!hasSchool || periodIndex == null || periods == null) {
			return;
		}

		// For all periods starting from periodIndex, schedule applicable reminders.
		for (int index = periodIndex!; index < periods!.length; index++) {
			final Period period = periods! [index];
			for (final int reminderIndex in reminders.getReminders(
				period: period.period,
				subject: subjects [period.id]?.name,
				dayName: today?.name,
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
						message: reminders.reminders [reminderIndex].message,
					)
				);
			}
		}
	}

	/// Determines whether a reminder is compatible with the user's schedule. 
	/// 
	/// If [User.dayNames] has changed, then reminders with [PeriodReminderTime]
	/// might fail. Similarly, if the user changes classes, [SubjectReminderTime]
	/// might fail. This method helps the app spot these inconsistencies and get
	/// rid of the problematic reminders. 
	bool isValidReminder(Reminder reminder) {
		switch(reminder.time.type) {
			case ReminderTimeType.period: 
				final PeriodReminderTime time = reminder.time as PeriodReminderTime;
				final Iterable<String> dayNames = user.schedule.keys;
				return dayNames.contains(time.dayName) 
					&& int.parse(time.period) <= user.schedule [time.dayName]!.length;
			case ReminderTimeType.subject: 
				final SubjectReminderTime time = reminder.time as SubjectReminderTime;
				return subjects.values.any((Subject subject) => subject.name == time.name);
			default: throw StateError("Reminder <$reminder> has invalid ReminderTime");
		}
	}
}
