import "package:flutter/foundation.dart" show ChangeNotifier;

import "schedule.dart";
import "sports.dart";

import "package:ramaz/services_collection.dart";

class HomeModel with ChangeNotifier {
	final Schedule schedule;
	final Sports sports;

	HomeModel(ServicesCollection services) :
		schedule = services.schedule,
		sports = services.sports
	{
		schedule.addListener(notifyListeners);
		sports.addListener(notifyListeners);
	}

	@override
	void dispose() {
		schedule.removeListener(notifyListeners);
		sports.removeListener(notifyListeners);
		super.dispose();
	}
}