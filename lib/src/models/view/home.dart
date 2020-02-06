import "package:flutter/foundation.dart";

import "package:ramaz/models.dart";
import "package:ramaz/services_collection.dart";

// ignore: prefer_mixin
class HomeModel with ChangeNotifier {
	final Schedule schedule; 
	final Sports sports;

	HomeModel(ServicesCollection services) : 
		schedule = services.schedule,
		sports = Sports(services.reader)
	{
		schedule.addListener(listener);
		sports.addListener(listener);
	}

	void listener() => notifyListeners();

	@override
	void dispose() {
		schedule.removeListener(listener);
		sports.removeListener(listener);
		super.dispose();
	}
}
