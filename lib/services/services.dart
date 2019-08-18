import "package:flutter/foundation.dart" show required;

import "reader.dart";
import "preferences.dart";
import "notes.dart";

class ServicesCollection {
	final Reader reader;
	final Preferences prefs;

	final Notes notes;

	ServicesCollection({
		@required this.reader,
		@required this.prefs,
	}) : notes = Notes (reader);
}
