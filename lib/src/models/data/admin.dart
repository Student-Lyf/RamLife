import "package:ramaz/services.dart";

import "admin/calendar.dart";
import "admin/user.dart";

export "admin/calendar.dart";
export "admin/user.dart";

/// A data model that manages all admin responsibilities. 
class AdminModel {
	CalendarModel _calendar;
	
	/// The admin user this model is managing. 
	/// 
	/// This is an [AdminUserModel], not just the user itself. 
	AdminUserModel user;

	Future<void> init() async {
		user = AdminUserModel(
			json: await Services.instance.admin, 
			scopes: await Auth.adminScopes
		);
	}

	/// The data model for modifying the calendar. 
	CalendarModel get calendar => _calendar ??= CalendarModel();
}