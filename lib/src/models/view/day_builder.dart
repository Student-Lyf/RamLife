import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

// ignore: prefer_mixin
class DayBuilderModel with ChangeNotifier {
	final AdminUserModel admin;
	Letters _letter;
	Special _special;

	DayBuilderModel(AdminModel adminModel) : admin = adminModel.user {
		admin.addListener(notifyListeners);
	}

	@override 
	void dispose() {
		admin.removeListener(notifyListeners);
		super.dispose();
	}

	Letters get letter => _letter;
	set letter (Letters value) {
		_letter = value;
		notifyListeners();
	}

	Special get special => _special;
	set special (Special value) {
		if (value == null) {
			return;
		}
		_special = value;
		if(
			!presetSpecials.any(
				(Special preset) => preset.name == value.name
			) && !userSpecials.any(
				(Special preset) => preset.name == value.name
			)
		) {
			admin.addSpecial(value);
		}

		notifyListeners();
	}
	
	Day get day => Day (letter: letter, special: special);
	List<Special> get presetSpecials => Special.specials;
	List<Special> get userSpecials => admin.admin.specials;

	bool get ready => letter != null && special != null;
}
