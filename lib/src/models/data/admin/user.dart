import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A data model to manage an [Admin] user.
///
/// While the [Admin] class handles admin data, this class handles syncing
/// the admin's data to the database.
// ignore: prefer_mixin
class AdminUserModel with ChangeNotifier {
	/// The admin being managed by this model.
	final Admin admin;

	/// Creates a data model to manage admin data.
	AdminUserModel({
		@required Map<String, dynamic> json, 
		@required List<String> scopes
	}) : admin = Admin.fromJson(json, scopes);

	/// The list of this admin's custom [Special]s.
	List<Special> get specials => admin.specials;

	/// Saves the admin's data both to the device and the cloud.
	Future<void> save() async {
		await Services.instance.database.setAdmin(admin.toJson());
		notifyListeners();
	}

	/// Adds a [Special] to the admin's list of custom specials.
	void addSpecial(Special special) {
		if (special == null) {
			return;
		}
		admin.specials.add(special);
		save();
	}

	/// Replaces a [Special] in the admin's list of custom specials.
	void replaceSpecial(int index, Special special) {
		if (special == null) {
			return;
		}
		admin.specials [index] = special;
		save();
	}

	/// Removes a [Special] in the admin's list of custom specials.
	void removeSpecial(int index) {
		admin.specials.removeAt(index);
		save();
	}
}
