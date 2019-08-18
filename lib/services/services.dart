import "package:flutter/foundation.dart" show required;

import "reader.dart";
import "preferences.dart";
import "notes.dart";
import "schedule.dart";

class ServicesCollection {
	final Reader reader;
	final Preferences prefs;

	Notes notes;
	Schedule schedule;

	ServicesCollection({
		@required this.reader,
		@required this.prefs,
	});

	/// This function is a safety!
	/// In the event a file is unavailable, the try, catch in main will catch it
	/// After the files are verifiably available, this function is called. 
	///
	/// Use this function to initialize anything that requires a file.
	void init() {
		notes = Notes (reader);
		schedule = Schedule(
			reader, 
			notes: notes,
		);
		verify();
	}

	/// Since [init] cannot be enforced, this function does null checks.
	/// Put any variables that aren't final in here
	void verify() {
		final List properties = [notes, schedule];

		for (final property in properties) assert (
			property != null,
			"ServicesCollection.init was not called"
		);
	}
}
