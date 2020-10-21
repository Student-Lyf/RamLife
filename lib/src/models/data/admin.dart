import "package:ramaz/services.dart";

import "admin/calendar.dart";
import "admin/user.dart";
import "model.dart";

export "admin/calendar.dart";
export "admin/user.dart";

/// A data model that manages all admin responsibilities. 
class AdminModel extends Model {
	CalendarModel _calendar;
	
	/// The admin user this model is managing. 
	/// 
	/// This is an [AdminUserModel], not just the user itself. 
	AdminUserModel user;

	@override
	Future<void> init() async {
		user = AdminUserModel(
			json: await Services.instance.database.admin, 
			scopes: await Auth.adminScopes
		);
	}

	/// The data model for modifying the calendar. 
	CalendarModel get calendar => _calendar ??= CalendarModel();
}