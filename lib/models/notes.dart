import "package:flutter/foundation.dart";

import "package:ramaz/services/firestore.dart" show saveNotes;
import "package:ramaz/services/reader.dart";

import "package:ramaz/data/note.dart";
import "package:ramaz/data/schedule.dart";

class NotesPageModel with ChangeNotifier {
	final Reader reader;
	final List<Note> notes;

	NotesPageModel({
		@required this.reader,
	}) : notes = reader.notes;

	Future<void> saveNote(Note note) async {
		notes.add(note);
		saveNotes(notes);
	}
}

class RepeatOption {
	final RepeatableType type;
	final Repeatable repeat;

	const RepeatOption({
		@required this.type,
		@required this.repeat,
	});
}

class NotesBuilderModel with ChangeNotifier {
	String message;
	RepeatableType type;
	Repeatable repeat;

	// For RepeatablePeriod(AndDay)
	Letters letter;
	String period;

	// For RepeatableSubject
	String name;

	Note build() {
		if (message == null) throw ArgumentError.notNull("message");
		Repeatable repeat;
		switch (type) {
			case RepeatableType.period:
				if (letter == null) throw ArgumentError.notNull("letter");
				else if (period == null) throw ArgumentError.notNull("period");
				else repeat = RepeatablePeriod(
					letter: letter,
					period: period,
				);
				break;
			// case RepeatableType.periodAndDay:
			// 	if (letter == null) throw ArgumentError.notNull("letter");
			// 	else if (period == null) throw ArgumentError.notNull("period");
			// 	else repeat = RepeatablePeriodAndDay(
			// 		letter: letter,
			// 		period: period,
			// 	); 
			// 	break;
			case RepeatableType.subject: 
				if (name == null) throw ArgumentError.notNull("name");
				else repeat = RepeatableSubject(
					name: name,
				);
				break;
		}
		return Note (message: message, repeat: repeat);
	}

	void onMessageChanged(String newMessage) {
		message = newMessage;
		notifyListeners();
	}

	bool get ready => message.isNotEmpty;
}