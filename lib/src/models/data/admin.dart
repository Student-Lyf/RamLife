import "package:ramaz/services_collection.dart";

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

	/// Creates an admin data model. 
	AdminModel(ServicesCollection services, List<String> scopes) : 
		user = AdminUserModel(services.reader, scopes);

	/// The data model for modifying the calendar. 
	CalendarModel get calendar => _calendar ??= CalendarModel();
}