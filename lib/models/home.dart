import "package:flutter/foundation.dart" show ChangeNotifier, required;
import "dart:async" show Timer;

import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/note.dart";

import "package:ramaz/models/notes.dart";

import "package:ramaz/services/auth.dart" as Auth;
import "package:ramaz/services/reader.dart";
import "package:ramaz/services/services.dart";

class HomeModel with ChangeNotifier {
	static const Duration minute = Duration (minutes: 1);

	final Reader reader;
	final ServicesCollection services;
	final NoteEditor noteModel;

	Timer timer;
	List<int> currentNotes, nextNotes;
	bool googleSupport = true;

	HomeModel (this.services) : 
		noteModel = NoteEditor(services),
		reader = services.reader
	{
		noteModel.addListener(onNotesChanged);
		updatePeriod();
		timer = Timer.periodic (minute, updatePeriod);
		checkGoogleSupport();
	}

	@override void dispose() {
		timer.cancel();
		super.dispose();
	}

	Subject getSubject(Period period) => reader.subjects[period.id];
	Day get today => reader.today;
	bool get school => today.school;
	Period get period => reader.period;
	Period get nextPeriod => reader.nextPeriod;

	Future<void> updatePeriod([_]) async {  // pull-to-refresh wants a Future
		updateNotes();
		notifyListeners();
	}

	void updateNotes() {
		currentNotes = Note.getNotes(
			notes: noteModel.notes,
			period: period?.period,
			letter: today.letter,
			subject: reader.subjects [period?.id],
		).toList();
		nextNotes = Note.getNotes(
			notes: noteModel.notes,
			period: nextPeriod?.period,
			letter: today.letter,
			subject: reader.subjects [nextPeriod?.id],
		).toList();
	}

	void onNotesChanged() {
		updateNotes();
		notifyListeners();
	}

	void checkGoogleSupport() async {
		googleSupport = await Auth.supportsGoogle();
		notifyListeners();
	}

	void addGoogleSupport({
		@required void Function() onFailure,
		@required void Function() onSuccess,
	}) async {
		final account = await Auth.signInWithGoogle(onFailure, link: true);
		if (account == null) return;
		googleSupport = true;
		notifyListeners();
		onSuccess();
	}
}
