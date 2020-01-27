import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A data model to manage an [Admin] user. 
/// 
/// While the [Admin] class handles admin data, this class handles syncing 
/// the admin's data to the database. 
// ignore: prefer_mixin
class AdminUserModel with ChangeNotifier {
	/// Provides access to the file system
	final Reader reader;

	/// The admin being managed by this model. 
	final Admin admin;

	/// Creates a data model to manage admin data. 
	AdminUserModel(this.reader) :
		admin = Admin.fromJson(reader.adminData);

	/// The list of this admin's custom [Special]s. 
	List<Special> get specials => admin.specials;


	/// Saves the admin's data both to the device and the cloud. 
	Future<void> save() async {
		reader.adminData = admin.toJson();
		notifyListeners();
		await Firestore.saveAdmin(admin.toJson());
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
