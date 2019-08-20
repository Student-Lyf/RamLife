import "package:flutter/foundation.dart";

import "package:ramaz/services/schedule.dart";
import "package:ramaz/services/services.dart";

import "package:ramaz/data/note.dart";
import "package:ramaz/data/schedule.dart";

class NotesBuilderModel with ChangeNotifier {
	final Schedule schedule;

	NoteTimeType type;
	NoteTime time;

	String message = "";
	bool shouldRepeat = false;

	// For RepeatablePeriod
	Day day;
	String period;

	// For RepeatableSubject
	String name;

	NotesBuilderModel({
		@required ServicesCollection services, 
		Note note
	}) : schedule = services.schedule {
		if (note == null) return;

		message = note.message;
		time = note.time;	

		shouldRepeat = time.repeats;
		type = time.type;
		switch (type) {
			case NoteTimeType.period: 
				period = (time as PeriodNoteTime).period;
				day = Day (letter: (time as PeriodNoteTime).letter);
				break;
			case NoteTimeType.subject:
				name = (time as SubjectNoteTime).name;
				break;
			default: 
				throw ArgumentError.notNull("Note.time.type");
		}
	}

	Note build() => Note (
		message: message, 
		time: NoteTime.fromType(
			type: type,
			letter: letter,
			period: period,
			name: name,
			repeats: shouldRepeat,
		),
	);

	bool get ready => (
		(message?.isNotEmpty ?? false) && type != null && 
		(type != NoteTimeType.period ||
			(day?.letter != null && period != null)
		) && (
			type != NoteTimeType.subject || name != null			
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

	void toggleRepeatType(NoteTimeType value) {
		type = value;
		notifyListeners();
	}

	void changeLetter(Letters value) {
		day = Day (letter: value);
		period = null;
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
