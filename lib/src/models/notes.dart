import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A DataModel that keeps the state of the user's notes. 
/// 
/// This data model abstracts all operations that have to do with notes, 
/// and all other parts of the app that want to operate on notes should use
/// this data model.
class Notes with ChangeNotifier {
	final Reader _reader;

	/// The notes for the user.
	List<Note> notes;

	/// The notes that apply for this period. 
	/// 
	/// This is managed by the Schedule data model.
	List<int> currentNotes;

	/// The notes that apply for next period.
	/// 
	/// This is managed by the Schedule data model.
	List<int> nextNotes;

	/// Notes that applied for previous periods. 
	/// 
	/// These notes will be marked for deletion if they do not repeat.
	List<int> readNotes;

	/// Creates a Notes data model. 
	/// 
	/// This automatically calls [setup].
	Notes(this._reader) {setup();}

	/// Initializes this data model.
	/// 
	/// This function should be called any time completely new data is available.
	void setup() {
		final Map<String, dynamic> data = _reader.notesData;
		readNotes = List<int>.from(data ["read"] ?? []);
		notes = [
			for (final json in data ["notes"] ?? [])
				Note.fromJson(json)
		];
		notifyListeners();
	}

	/// Whether any note applies to the current period.
	bool get hasNote => currentNotes.isNotEmpty;
		
	/// Marks a note as "shown".
	/// 
	/// It will then be marked for deletion if it does not repeat.
	/// See [readNotes] and [cleanNotes] for details.
	void markShown(int index) {
		if (readNotes.contains(index)) return;
		readNotes.add(index);
		cleanNotes();
		updateNotes();
	}

	/// Gets all notes that apply to the a given period. 
	/// 
	/// This method is a wrapper around [Note.getNotes], and should only be 
	/// called by an object with access to the relevant period, ie, Schedule. 
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

	/// Saves all notes to the device and the cloud. 
	/// 
	/// This method sets [Reader.notesData] and calls [Firestore.saveNotes].
	void saveNotes() {
		_reader.notesData = {
			"notes": notes.map(
					(Note note) => note.toJson()
				).toList(),
			"read": readNotes ?? [],
		};
		Firestore.saveNotes(notes ?? [], readNotes ?? []);
	}

	/// Checks if any notes have been modified and removes them. 
	/// 
	/// This makes sure that any notes in [currentNotes], [nextNotes], and 
	/// [readNotes] are all up-to-date. 
	void verifyNotes(int changedIndex) {
		for (final List<int> notesList in [currentNotes, nextNotes, readNotes]) {
			int toRemove;
			for (final int index in notesList ?? []) {
				if (index == changedIndex) {
					toRemove = index;
					break;
				}
			}
			if (toRemove != null) notesList.removeAt(toRemove);
		}
	}

	/// Runs errands whenever notes have changed. 
	/// 
	/// Does the following: 
	/// 
	/// 	1. Runs [verifyNotes] (if a note has changed and not simply added).
	/// 	2. Runs [saveNotes].
	/// 	3. Calls [notifyListeners].
	/// 	
	void updateNotes([int changedIndex]) {
		if (changedIndex != null) 
			verifyNotes(changedIndex);
		saveNotes();
		notifyListeners();
	}

	/// Replaces a note at a given index. 
	void replaceNote(int index, Note note) {
		if (note == null) return;
		notes.removeAt(index);
		notes.insert(index, note);
		updateNotes(index);
	}

	/// Adds a note to the notes list. 
	/// 
	/// Use this method instead of simply `notes.add` to 
	/// ensure that `updateNotes` is called. 
	void addNote(Note note) {
		if (note == null) return;
		notes.add(note);
		updateNotes();
	}

	/// Deletes the note at a given index.
	/// 
	/// Use this insead of `notes.removeAt` to ensure that `updateNotes` is called.
	void deleteNote(int index) {
		notes.removeAt(index);
		updateNotes(index);
	}

	/// Deletes expired notes. 
	/// 
	/// This method searches all notes in [readNotes] for a note that does not 
	/// repeat and has been shown already (ie, in [currentNotes]), then calls 
	/// [deleteNote] on them. 
	void cleanNotes() {
		final List<Note> toRemove = [];
		for (final int index in readNotes) {
			final Note note = notes[index];
			if (
				!note.time.repeats && !currentNotes.contains(index)
			) toRemove.add (note);
		}
		for (final Note note in toRemove) {
			print ("Note expired: $note");
			deleteNote(notes.indexOf(note));
		}
	}
}
