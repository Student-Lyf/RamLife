import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

import "model.dart";

/// A data model to hold [User] and [Admin] objects. 
/// 
/// This data model doesn't really update, however it's a convenient place to 
/// keep the user object. Any functionality relating to the admin is also 
/// implemented here, so that the code for updating both the database and the 
/// UI is in one place. 
class UserModel extends Model {
	/// The user object. 
	late User data;

	/// The admin object. 
	/// 
	/// If the user is not an admin ([Auth.isAdmin]) is false, this will be null. 
	Admin? admin;

	/// The subjects this user has. 
	/// 
	/// For students this will be the courses they attend. For teachers, this 
	/// will be the courses they teach. 
	late Map<String, Subject> subjects;

	/// Whether this user is an admin. 
	/// 
	/// Unlike [Auth.isAdmin], which authenticates with the server, this getter
	/// simply checks to see if [admin] was initialized. 
	bool get isAdmin => admin != null;

	@override
	Future<void> init() async {
		data = User.fromJson(await Services.instance.database.user);
		subjects = Subject.getSubjects(
			await Services.instance.database.getSections(data.sectionIDs)
		);
		if (await Auth.isAdmin) {
			admin = Admin.fromJson(
				await Services.instance.database.admin,
				// if this object is created, the user is an admin
				(await Auth.adminScopes)!,  
			);
		}
	}

	/// Saves the admin data to the database. 
	Future<void> saveAdmin() async {
		await Services.instance.database.setAdmin(admin!.toJson());
		notifyListeners();
	}

	/// Adds a custom [Special] to the admin's profile. 
	Future<void> addSpecialToAdmin(Special? special) async {
		if (special == null) {
			return;
		}
		admin!.specials.add(special);
		return saveAdmin();
	}

	/// Replaces the custom [Special] at the given index in the user's profile. 
	Future<void> replaceAdminSpecial(int index, Special? special) async {
		if (special == null) {
			return;
		}
		admin?.specials [index] = special;
		return saveAdmin();
	}

	/// Removes a custom [Special] at a given index from the user's profile.
	Future<void> removeSpecialFromAdmin(int index) {
		admin!.specials.removeAt(index);
		return saveAdmin();
	}
}
