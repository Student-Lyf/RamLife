import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

import "model.dart";

/// A data model to hold and initialize the [User] object. 
/// 
/// This data model doesn't really update, however it's a convenient place to 
/// keep the user object. Any functionality relating to the admin is also 
/// implemented here, so that the code for updating both the database and the 
/// UI is in one place. 
class UserModel extends Model {
	/// The user object. 
	late User data;

	/// The subjects this user has. 
	/// 
	/// For students this will be the courses they attend. For teachers, this 
	/// will be the courses they teach. 
	late Map<String, Subject> subjects;

	/// The permissions this user has, if they are an administrator. 
	List<AdminScope>? adminScopes;

	/// Whether this user is an admin. 
	/// 
	/// Unlike [Auth.isAdmin], which authenticates with the server, this getter
	/// simply checks to see if [adminScopes] was initialized.
	bool get isAdmin => adminScopes != null;

	@override
	Future<void> init() async {
		data = User.fromJson(await Services.instance.database.user.getProfile());
		subjects = {
			for (final String id in data.sectionIDs)
				id: Subject.fromJson(
					await Services.instance.database.schedule.getCourse(id)
				)
		};
		final List<String>? scopeStrings = await Auth.adminScopes;
		adminScopes = scopeStrings == null ? null : [
			for (final String scope in scopeStrings)
				parseAdminScope(scope)
		];
	}
}
