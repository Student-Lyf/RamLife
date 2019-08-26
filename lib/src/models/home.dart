import "package:flutter/foundation.dart" show ChangeNotifier, required;

import "schedule.dart";

import "package:ramaz/services.dart";
import "package:ramaz/services_collection.dart";

class HomeModel with ChangeNotifier {
	static const Duration minute = Duration (minutes: 1);

	final Schedule schedule;
	final ServicesCollection services;
	// final Notes notes;

	bool googleSupport = true;

	HomeModel (this.services) :
		schedule = services.schedule
	{
		schedule.addListener(notifyListeners);
		checkGoogleSupport();
	}

	@override 
	void dispose() {
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
