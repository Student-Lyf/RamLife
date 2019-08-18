import "package:flutter/foundation.dart";

import "package:ramaz/data/note.dart";
import "package:ramaz/data/schedule.dart" show Letters;

import "reader.dart";
import "firestore.dart" as Firestore;

class Notes with ChangeNotifier {
	final Reader reader;
	final List<Note> notes;

	List<int> currentNotes;

	Notes(this.reader) : 
		notes = Note.fromList (reader.notesData);

	bool get hasNote => currentNotes.isNotEmpty;

	void setNotes({
		@required String subject,
		@required String period,
		@required Letters letter,
	}) {
		currentNotes = Note.getNotes(
			notes: notes,
			subject: subject,
			letter: letter,
			period: period,
		).toList();
		notifyListeners();
	}

	void saveNotesToReader() {
		reader.notesData = notes.map(
			(Note note) => note.toJson()
		).toList();
	}

	void updateNotes() {
		Firestore.saveNotes(notes);  // upload to firestore
		saveNotesToReader();
		notifyListeners();
	}

	void replaceNote(int index, Note note) {
		if (note == null) return;
		notes.removeAt(index);
		notes.insert(index, note);
		updateNotes();
	}

	void addNote(Note note) {
		if (note == null) return;
		notes.add(note);
		updateNotes();
	}

	void deleteNote(int index) {
		notes.removeAt(index);
		updateNotes();
	}
}