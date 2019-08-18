import "package:flutter/foundation.dart";

import "package:ramaz/services/schedule.dart" as ScheduleTracker;
import "package:ramaz/services/services.dart";

import "package:ramaz/data/note.dart";
import "package:ramaz/data/schedule.dart";

class NotesBuilderModel with ChangeNotifier {
	final ScheduleTracker.Schedule schedule;

	RepeatableType type;
	Repeatable repeat;
	Day day;

	String message = "";
	bool shouldRepeat = false;

	// For RepeatablePeriod
	String period;

	// For RepeatableSubject
	String name;

	NotesBuilderModel({
		@required ServicesCollection services, 
		Note note
	}) : schedule = services.schedule {
		if (note == null) return;

		message = note.message;
		repeat = note.repeat;	
		shouldRepeat = repeat != null;
		if (repeat == null) return;

		type = repeat.type;
		switch (type) {
			case RepeatableType.period: 
				period = (repeat as RepeatablePeriod).period;
				day = Day (letter: (repeat as RepeatablePeriod).letter);
				break;
			case RepeatableType.subject:
				name = (repeat as RepeatableSubject).name;
				break;
			default: 
				throw ArgumentError.notNull("Note.repeat.type");
		}
	}

	Note build() => Note (
		message: message, 
		repeat: !shouldRepeat ? null : Repeatable.fromType(
			type: type,
			letter: letter,
			period: period,
			course: name,
		),
	);

	bool get ready => (
		(message?.isNotEmpty ?? false) &&
		(!shouldRepeat || type != null) &&
		(type != RepeatableType.period ||
			(day?.letter != null && period != null)
		) && (
			type != RepeatableType.subject || name != null			
		)
	);

	Iterable<String> get periods => day == null ? null 
		: schedule.student.getPeriods(day).map(
			(Period period) => period.period,
		);

	Iterable<String> get courses => schedule.subjects.values.map(
		(Subject subject) => subject.name
	);

	Letters get letter => day?.letter;

	void onMessageChanged(String newMessage) {
		message = newMessage;
		notifyListeners();
	}

	void toggleRepeat(bool value) {
		shouldRepeat = value;
		notifyListeners();
	}

	void toggleRepeatType(RepeatableType value) {
		type = value;
		notifyListeners();
	}

	void changeLetter(Letters value) {
		day = Day (letter: value);
		notifyListeners();
	}

	void changePeriod(String value) {
		period = value;
		notifyListeners();
	}

	void changeCourse(String value) {
		name = value;
		notifyListeners();
	}
}
