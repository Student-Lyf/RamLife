import "package:flutter/foundation.dart";

import "package:ramaz/data/note.dart";
import "reader.dart";
import "firestore.dart" as Firestore;

class Notes with ChangeNotifier {
	final Reader reader;
	final List<Note> notes;

	bool _hasNote;

	Notes(this.reader) : 
		notes = Note.fromList (reader.notesData);

	bool get hasNote => _hasNote ?? false;
	set hasNote(bool value) {
		_hasNote = value;
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