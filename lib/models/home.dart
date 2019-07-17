import "package:flutter/foundation.dart" show ChangeNotifier, required;
import "dart:async" show Timer;

import "package:ramaz/data/schedule.dart";
import "package:ramaz/services/auth.dart" as Auth;
import "package:ramaz/services/reader.dart";
import "package:ramaz/services/preferences.dart";

class HomeModel with ChangeNotifier {
	static const Duration minute = Duration (minutes: 1);

	final Reader reader;
	final Preferences prefs;
	Period period, nextPeriod; 
	Schedule schedule;
	Day today;

	Timer timer;
	List<Period> periods;
	int periodIndex;
	bool googleSupport = true;

	HomeModel ({
		@required this.reader,	
		@required this.prefs,	
	}) {
		today = reader.today;
		reader.currentDay = today;
		schedule = reader.student.schedule [today.letter];
		periods = reader.student.getPeriods(today);
		// periodIndex = today.period;
		updatePeriod();
		reader.period = nextPeriod;
		timer = Timer.periodic (minute, updatePeriod);
		checkGoogleSupport();
	}

	@override void dispose() {
		timer.cancel();
		super.dispose();
	}

	Subject getSubject(Period period) => reader.subjects[period.id];
	bool get school => today.school;

	Future<void> updatePeriod([_]) async {  // pull-to-refresh wants a Future
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
