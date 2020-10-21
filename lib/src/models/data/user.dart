import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

import "model.dart";

class UserModel extends Model {
	User data;
	Admin admin;
	Map<String, Subject> subjects;

	bool get isAdmin => admin == null;

	@override
	Future<void> init() async {
		data = User.fromJson(await Services.instance.database.user);
		subjects = Subject.getSubjects(
			await Services.instance.database.getSections(data.sectionIDs)
		);
		if (await Auth.isAdmin) {
			admin = Admin.fromJson(
				await Services.instance.database.admin,
				await Auth.adminScopes,
			);
		}
	}

	Future<void> saveAdmin() async {
		await Services.instance.database.setAdmin(admin.toJson());
		notifyListeners();
	}

	Future<void> addSpecialToAdmin(Special special) async {
		if (special == null) {
			return;
		}
		admin.specials.add(special);
		return saveAdmin();
	}

	Future<void> replaceAdminSpecial(int index, Special special) async {
		if (special == null) {
			return;
		}
		admin.specials [index] = special;
		return saveAdmin();
	}

	Future<void> removeSpecialFromAdmin(int index) {
		admin.specials.removeAt(index);
		return saveAdmin();
	}
}
