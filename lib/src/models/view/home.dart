import "package:flutter/foundation.dart";

import "package:ramaz/models.dart";

// ignore: prefer_mixin
class HomeModel with ChangeNotifier {
	// Do NOT use a list here. See null checks in [dispose].
	HomeModel() {
		Models.instance.schedule.addListener(notifyListeners);
		Models.instance.sports.addListener(notifyListeners);
	}

	@override
	void dispose() {
		Models.instance?.schedule?.removeListener(notifyListeners);
		Models.instance?.sports?.removeListener(notifyListeners);
		super.dispose();
	}
}
