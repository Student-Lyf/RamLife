import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/services_collection.dart";

/// A view model for the dialog that allows the user to build a reminder.
// ignore: prefer_mixin
class RemindersBuilderModel with ChangeNotifier {
	final Schedule _schedule;

	/// The type of reminder the user is building. 
	ReminderTimeType type;

	/// The time this reminder will be displayed.
	ReminderTime time;

	/// The message for this reminder.
	String message = "";

	/// Whether this reminder repeats.
	/// 
	/// This affects whether it will be deleted after 
	/// being displayed once. 
	bool shouldRepeat = false;

	/// The day this reminder should be displayed.
	/// 
	/// Only relevant for [PeriodReminderTime].
	Day day;

	/// The period this reminder should be displayed.
	/// 
	/// Only relevant for [PeriodReminderTime].
	String period;

	/// The name of the class this reminder should be displayed.
	/// 
	/// Only relevant for [SubjectReminderTime].
	String course;

	/// All the names of the user's courses. 
	final List<String> courses;

	/// Creates a new reminder builder model.
	/// 
	/// If [reminder] is not null, then the relevant fields of this 
	/// class are filled in with the corresponding fields of the reminder. 
	RemindersBuilderModel({
		@required ServicesCollection services, 
		Reminder reminder
	}) : 
		_schedule = services.schedule,
		courses = [
			for (final Subject subject in services.schedule.subjects.values)
				subject.name
		]
	{
		if (reminder == null) {
			return;
		}

		message = reminder.message;
		time = reminder.time;	

		shouldRepeat = time.repeats;
		type = time.type;
		switch (type) {
			case ReminderTimeType.period: 
				final PeriodReminderTime reminderTime = time;
				period = reminderTime.period;
				day = Day (letter: reminderTime.letter);
				break;
			case ReminderTimeType.subject:
				final SubjectReminderTime reminderTime = time;
				course = reminderTime.name;
				break;
			default: 
				throw ArgumentError.notNull("Reminder.time.type");
		}
	}

	/// Returns a new reminder from the model's fields.
	Reminder build() => Reminder (
		message: message, 
		time: ReminderTime.fromType(
			type: type,
			letter: letter,
			period: period,
			name: course,
			repeats: shouldRepeat,
		),
	);

	/// Whether the dialog is ready to submit. 
	/// 
	/// In a nutshell, this field will be false if: 
	/// 
	/// - [message] is null or empty,
	/// - [type] is null,
	/// - [type] is [ReminderTimeType.period] and [letter] or [period] is null, or
	/// - [type] is [ReminderTimeType.subject] and [course] is null.
	/// 
	bool get ready => (message?.isNotEmpty ?? false) && 
		type != null &&
		(type != ReminderTimeType.period ||
			(day?.letter != null && period != null)
		) && (
			type != ReminderTimeType.subject || course != null			
		);

	/// A list of all the periods in [day].
	/// 
	/// Make sure this field is only accessed *after* setting [day].
	List<String> get periods => day == null ? null : [
		for (final Period period in _schedule.student.getPeriods(day))
			period.period
	];

	/// The selected letter.
	Letters get letter => day?.letter;

	/// Sets the message to the given string.
	/// 
	/// Use this to properly update [ready].
	void onMessageChanged(String newMessage) {
		message = newMessage;
		notifyListeners();
	}

	/// Toggles whether this reminder should repeat. 
	// ignore: avoid_positional_boolean_parameters
	void toggleRepeat(bool value) {
		shouldRepeat = value;
		notifyListeners();
	}

	/// Changes the [type] of this reminder.
	void toggleRepeatType(ReminderTimeType value) {
		type = value;
		notifyListeners();
	}

	/// Changes the [period] of this reminder. 
	/// 
	/// Only relevant when [type] is [ReminderTimeType.period].
	void changeLetter(Letters value) {
		day = Day (letter: value);
		period = null;
		notifyListeners();
	}

	/// Changes the [period] of this reminder. 
	/// 
	/// Only relevant when [type] is [ReminderTimeType.period]
	void changePeriod(String value) {
		period = value;
		notifyListeners();
	}

	/// Changes the [course] of this reminder. 
	/// 
	/// Only relevant when [type] is [ReminderTimeType.subject].
	void changeCourse(String value) {
		course = value;
		notifyListeners();
	}
}
