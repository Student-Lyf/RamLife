import "package:flutter/foundation.dart";

import "package:ramaz/services/firestore.dart" show saveNotes;
import "package:ramaz/services/reader.dart";

import "package:ramaz/data/note.dart";
import "package:ramaz/data/schedule.dart";

import "package:ramaz/models/schedule.dart";

class NotesPageModel with ChangeNotifier {
	final Reader reader;
	final List<Note> notes;

	NotesPageModel({
		@required this.reader,
	}) : notes = reader.notes;

	void updateNotes() {
		notifyListeners();
		Future (
			() {
				saveNotes(notes);
				reader.notes = notes;  // holds notes in memory
				reader.notesData = notes;  // writes to file
			}
		);
	}

	void saveNote(Note note) {
		if (note == null) return;
		notes.add(note);
		updateNotes();
	}

	void replace(int index, Note note) {
		if (note == null) return;
		notes.removeAt (index);
		notes.insert(index, note);
		updateNotes();
	}

	void deleteNote(int index) {
		notes.removeAt (index);
		updateNotes();
	}
}

class NotesBuilderModel with ChangeNotifier {
	final Reader reader;
	ScheduleModel schedule;
	RepeatableType type;
	Repeatable repeat;
	Day day = Day (letter: Letters.M);

	String message;
	bool shouldRepeat = false;

	// For RepeatablePeriod(AndDay)
	Letters letter;
	String period;

	// For RepeatableSubject
	String name;

	NotesBuilderModel({@required this.reader, Note note}) {
		schedule = ScheduleModel(reader: reader);
		if (note == null) return;
		message = note.message;
		repeat = note.repeat;	
		shouldRepeat = repeat != null;
		if (repeat == null) return;
		type = repeat.type;
		switch (type) {
			case RepeatableType.period: 
				period = (repeat as RepeatablePeriod).period;
				letter = (repeat as RepeatablePeriod).letter;
				break;
			case RepeatableType.subject:
				name = (repeat as RepeatableSubject).name;
				break;
			default: 
				throw ArgumentError.notNull("Note.repeat.type");
		}
	}

	Note build() {
		if (message == null) throw ArgumentError.notNull("message");
		Repeatable repeatable;
		if (shouldRepeat) {
			switch (type) {
				case RepeatableType.period:
					if (letter == null) throw ArgumentError.notNull("letter");
					else if (period == null) throw ArgumentError.notNull("period");
					else repeatable = RepeatablePeriod(
						letter: letter,
						period: period,
					);
					break;
				// case RepeatableType.periodAndDay:
				// 	if (letter == null) throw ArgumentError.notNull("letter");
				// 	else if (period == null) throw ArgumentError.notNull("period");
				// 	else repeatable = RepeatablePeriodAndDay(
				// 		letter: letter,
				// 		period: period,
				// 	); 
				// 	break;
				case RepeatableType.subject: 
					if (name == null) throw ArgumentError.notNull("name");
					else repeatable = RepeatableSubject(
						name: name,
					);
					break;
			}
		}
		final Note result = Note (message: message, repeat: repeatable);
		return result;
	}

	void onMessageChanged(String newMessage) {
		message = newMessage;
		notifyListeners();
	}

	bool get ready => (
		(message?.isNotEmpty ?? false) &&
		(!shouldRepeat || type != null) &&
		(type != RepeatableType.period ||
			(letter != null && period != null)
		) && (
			type != RepeatableType.subject || name != null			
		)
	);

	void toggleRepeat(bool value) {
		shouldRepeat = value;
		notifyListeners();
	}

	void toggleRepeatType(RepeatableType value) {
		type = value;
		notifyListeners();
	}

	void changeLetter(Letters value) {
		letter = value;
		day = schedule.buildDay(day, newLetter: letter);
		notifyListeners();
	}

	Iterable<String> get periods => schedule.getPeriods(day).map(
		(Period period) => period.period,
	);

	void changePeriod(String value) {
		period = value;
		notifyListeners();
	}

	Iterable<String> get courses => reader.subjects.values.map(
		(Subject subject) => subject.name
	);

	void changeCourse(String value) {
		name = value;
		notifyListeners();
	}
}
