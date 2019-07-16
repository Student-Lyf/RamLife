import "package:flutter/foundation.dart" show ChangeNotifier, required;

import "package:ramaz/data/schedule.dart";
import "package:ramaz/services/reader.dart";
import "package:ramaz/services/preferences.dart";
import "package:ramaz/services/auth.dart" as Auth;

class HomeModel with ChangeNotifier {
	final Reader reader;
	final Preferences prefs;
	Period period, nextPeriod; 
	Schedule schedule;
	Day today;
	List<Period> periods;
	int periodIndex;
	bool googleSupport;

	HomeModel ({
		@required this.reader,	
		@required this.prefs,	
	}) {
		today = reader.today;
		reader.currentDay = today;
		schedule = reader.student.schedule [today.letter];
		periods = reader.student.getPeriods(today);
		reader.period = nextPeriod;
	}

	Subject getSubject(Period period) => reader.subjects[period.id];

	void updatePeriod() {
		if (!today.school) {
			period = null;
			nextPeriod = null;
			notifyListeners();
			return;
		}
		periodIndex = today.period;
		period = periodIndex == null ? null : periods [periodIndex];
		nextPeriod = periodIndex != null && periodIndex < periods.length - 1
			? periods [periodIndex + 1]
			: nextPeriod = null;
		notifyListeners();
	}

	void checkGoogleSupport() async {
		googleSupport = await Auth.supportsGoogle();
		notifyListeners();
	}

	void addGoogleSupport({
		void Function() callback, Future<void> Function() onSuccess
	}) async {
		final account = await Auth.signInWithGoogle(callback);
		if (account == null) return;
		googleSupport = true;
		notifyListeners();
		await onSuccess();
	}
}