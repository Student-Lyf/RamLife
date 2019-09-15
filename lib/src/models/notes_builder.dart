import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/services_collection.dart";

/// A view model for the dialog that allows the user to build a note. 
class NotesBuilderModel with ChangeNotifier {
	final Schedule _schedule;

	/// The type of note the user is building. 
	NoteTimeType type;

	/// The time this note will be displayed.
	NoteTime time;

	/// The message for this note.
	String message = "";

	/// Whether this note repeats.
	/// 
	/// This affects whether it will be deleted after 
	/// being displayed once. 
	bool shouldRepeat = false;

	/// The day this note should be displayed.
	/// 
	/// Only relevant for [PeriodNoteTime].
	Day day;

	/// The period this note should be displayed.
	/// 
	/// Only relevant for [PeriodNoteTime].
	String period;

	/// The name of the class this note should be displayed.
	/// 
	/// Only relevant for [SubjectNoteTime].
	String course;

	/// All the names of the user's courses. 
	final List<String> courses;

	/// Creates a new note builder model.
	/// 
	/// If [note] is not null, then the relevant fields of this 
	/// class are filled in with the corresponding fields of the note. 
	NotesBuilderModel({
		@required ServicesCollection services, 
		Note note
	}) : 
		_schedule = services.schedule,
		courses = [
			for (final Subject subject in services.schedule.subjects.values)
				subject.name
		]
	{
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
				course = (time as SubjectNoteTime).name;
				break;
			default: 
				throw ArgumentError.notNull("Note.time.type");
		}
	}

	/// Returns a new note from the model's fields.
	Note build() => Note (
		message: message, 
		time: NoteTime.fromType(
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
	/// 	- [message] is null or empty,
	/// 	- [type] is null,
	/// 	- [type] is [NoteTimeType.period] and [letter] or [period] is null, or
	/// 	- [type] is [NoteTimeType.subject] and [course] is null.
	/// 
	bool get ready => (
		(message?.isNotEmpty ?? false) && type != null && 
		(type != NoteTimeType.period ||
			(day?.letter != null && period != null)
		) && (
			type != NoteTimeType.subject || course != null			
		)
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

	/// Toggles whether this note should repeat. 
	void toggleRepeat(bool value) {
		shouldRepeat = value;
		notifyListeners();
	}

	/// Changes the [type] of this note.
	void toggleRepeatType(NoteTimeType value) {
		type = value;
		notifyListeners();
	}

	/// Changes the [period] of this note. 
	/// 
	/// Only relevant when [type] is [NoteTimeType.period].
	void changeLetter(Letters value) {
		day = Day (letter: value);
		period = null;
		notifyListeners();
	}

	/// Changes the [period] of this note. 
	/// 
	/// Only relevant when [type] is [NoteTimeType.period]
	void changePeriod(String value) {
		period = value;
		notifyListeners();
	}

	/// Changes the [course] of this note. 
	/// 
	/// Only relevant when [type] is [NoteTimeType.subject].
	void changeCourse(String value) {
		course = value;
		notifyListeners();
	}
}
