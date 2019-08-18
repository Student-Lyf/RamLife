import "package:flutter/foundation.dart" show required;

import "reader.dart";
import "preferences.dart";
import "notes.dart";

class ServicesCollection {
	final Reader reader;
	final Preferences prefs;

	Notes notes;

	ServicesCollection({
		@required this.reader,
		@required this.prefs,
	});

	void init() {
		notes = Notes (reader);
	}
}
