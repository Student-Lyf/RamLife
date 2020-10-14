import "package:flutter/foundation.dart";

import "package:ramaz/models.dart";

// ignore: prefer_mixin
class HomeModel with ChangeNotifier {
	// Do NOT use a list here. See null checks in [dispose].
	HomeModel() {
		Models.schedule.addListener(notifyListeners);
		Models.sports.addListener(notifyListeners);
	}

	@override
	void dispose() {
		Models?.schedule?.removeListener(notifyListeners);
		Models?.sports?.removeListener(notifyListeners);
		super.dispose();
	}
}
