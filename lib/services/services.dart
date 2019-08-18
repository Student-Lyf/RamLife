import "package:flutter/foundation.dart" show required;

import "reader.dart";
import "preferences.dart";

class ServicesCollection {
	final Reader reader;
	final Preferences prefs;

	const ServicesCollection({
		@required this.reader,
		@required this.prefs
	});
}
