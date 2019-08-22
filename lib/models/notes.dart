import "package:flutter/foundation.dart";

import "package:ramaz/data/note.dart";
import "package:ramaz/data/schedule.dart" show Letters;

import "package:ramaz/services/reader.dart";
import "package:ramaz/services/firestore.dart" as Firestore;

class Notes with ChangeNotifier {
	final Reader reader;

	List<Note> notes;
	List<int> currentNotes, nextNotes, readNotes;

	Notes(this.reader) {
		final Map<String, dynamic> data = reader.notesData;
		readNotes = List<int>.from(data ["read"]);
		notes = data ["notes"].map<Note>((json) => Note.fromJson(json)).toList();
	}

	bool get hasNote => currentNotes.isNotEmpty;
	set shown (int index) {
		if (readNotes.contains(index)) return;
		readNotes.add(index);
		updateNotes();
	}

	List<int> getNotes({
		@required String subject,
		@required String period,
		@required Letters letter,
	}) => Note.getNotes(
		notes: notes,
		subject: subject,
		letter: letter,
		period: period,
	).toList();

	void saveNotesToReader() {
		reader.notesData = {
			"notes": notes.map(
					(Note note) => note.toJson()
				).toList(),
			"read": readNotes,
		};
		Firestore.saveNotes(notes, readNotes);
	}

	void verifyNotes(int changedIndex) {
		int toRemove;
		if (currentNotes != null) {
			for (final int index in currentNotes) {
				if (index == changedIndex) {
					toRemove = index;
				}
			}
		}
		if (toRemove != null) currentNotes.removeAt(toRemove);
		if (nextNotes != null) {
			for (final int index in nextNotes) {
				if (index == changedIndex) {
					toRemove = index;
				}
			}
		}
		if (toRemove != null) nextNotes.removeAt(toRemove);
		if (readNotes != null) {
			for (final int index in readNotes) {
				if (index == changedIndex) 
					toRemove = index;
			}
		}
		if (toRemove != null) readNotes.removeAt(toRemove);
	}

	void updateNotes([int changedIndex]) {
		verifyNotes(changedIndex);
		Firestore.saveNotes(notes, readNotes);  // upload to firestore
		saveNotesToReader();
		notifyListeners();
	}

	void replaceNote(int index, Note note) {
		if (note == null) return;
		notes.removeAt(index);
		notes.insert(index, note);
		updateNotes(index);
	}

	void addNote(Note note) {
		if (note == null) return;
		notes.add(note);
		updateNotes();
	}

	void deleteNote(int index) {
		notes.removeAt(index);
		updateNotes(index);
	}

	void cleanNotes() {
		final List<Note> toRemove = [];
		for (final Note note in notes) {
			final int index = notes.indexOf(note);
			if (
				readNotes.contains(index) && 
				!note.time.repeats && 
				!currentNotes.contains(index)
			) 
				toRemove.add (note);
		}
		for (final Note note in toRemove) {
			print ("Note expired: $note");
			deleteNote(notes.indexOf(note));
		}
	}
}
