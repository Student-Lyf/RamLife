import "package:ramaz/services_collection.dart";

import "admin/admin.dart";
import "admin/calendar.dart";

export "admin/admin.dart";
export "admin/calendar.dart";

class AdminModel {
	CalendarModel _calendar;
	AdminUserModel user;

	AdminModel(ServicesCollection services) : 
		user = AdminUserModel(services.reader);

	CalendarModel get calendar => _calendar ??= CalendarModel();
}