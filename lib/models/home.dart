import "package:flutter/foundation.dart" show ChangeNotifier, required;

import "package:ramaz/services/notes.dart";
import "package:ramaz/services/auth.dart" as Auth;
import "package:ramaz/services/schedule.dart";
import "package:ramaz/services/services.dart";

class HomeModel with ChangeNotifier {
	static const Duration minute = Duration (minutes: 1);

	final Schedule schedule;
	final ServicesCollection services;
	final Notes notes;

	bool googleSupport = true;

	HomeModel (this.services) :
		schedule = services.schedule,
		notes = services.notes
	{
		notes.addListener(notifyListeners);
		schedule.addListener(notifyListeners);
		checkGoogleSupport();
	}

	@override 
	void dispose() {
		notes.removeListener(notifyListeners);
		schedule.removeListener(notifyListeners);
		super.dispose();
	}

	void checkGoogleSupport() async {
		googleSupport = await Auth.supportsGoogle();
		notifyListeners();
	}

	void addGoogleSupport({
		@required void Function() onSuccess,
		@required void Function() onFailure,
	}) async {
		final account = await Auth.signInWithGoogle(onFailure, link: true);
		if (account == null) return;
		googleSupport = true;
		notifyListeners();
		onSuccess();
	}
}
