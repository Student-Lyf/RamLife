/// An abstraction over data handling. 
/// 
/// This library can be split into two separate components: 
/// 
/// 1. Data models. 
/// 
/// 	Data models maintain the global state of the app. These models are 
/// 	responsible for pulling data from data sources (using services), and 
/// 	using that raw data to initialize data classes. 
/// 
/// 	By canonicalizing a single source of truth for all data, code duplication
/// 	and race conditions are avoided. 
/// 
/// 2. View models.
/// 
/// 	View models maintain the state of a single part of the UI, for example, 
/// 	a page, or dialog. These models dictate what properties and methods a 
/// 	UI element needs, and provides them, as well as how and when to update
/// 	the UI. Pages, for example, can now be stateless, and simply rely on 
/// 	the logic inherent in the view model to control their state. 
/// 
/// 	The point of a view model is to map fields to static UI elements and
/// 	methods to interactive ones. Every button and label that depends on 
/// 	state should depend on their corresponding view model.
library models;

import "package:ramaz/services.dart";

import "src/models/data/model.dart";
import "src/models/data/reminders.dart";
import "src/models/data/schedule.dart";
import "src/models/data/sports.dart";
import "src/models/data/user.dart";

// data models
export "src/models/data/reminders.dart";
export "src/models/data/schedule.dart";
export "src/models/data/sports.dart";
export "src/models/data/user.dart";

// view models
export "src/models/view/admin_schedules.dart";
export "src/models/view/builders/day_builder.dart";
export "src/models/view/builders/reminder_builder.dart";
export "src/models/view/builders/schedule_builder.dart";
export "src/models/view/builders/sports_builder.dart";
export "src/models/view/calendar_editor.dart";
export "src/models/view/feedback.dart";
export "src/models/view/home.dart";
export "src/models/view/schedule.dart";
export "src/models/view/sports.dart";
export "src/models/view/schedule_search.dart";

/// Bundles all the data models together. 
/// 
/// Each data model is responsible for different types of data. For example,
/// [ScheduleModel] keeps track of the schedule (as well as associated data such
/// as the current period) and [UserModel] reads the user data. 
/// 
/// Each data model inherits from [Model], so it has [init] and [dispose] 
/// functions. This model serves to bundles those together, so that calling
/// [init] or [dispose] on this model will call the respective functions 
/// on all the data models. 
class Models extends Model {
	/// The singleton instance of this class.
	static Models instance = Models();

	Reminders? _reminders;
	ScheduleModel? _schedule;
	Sports? _sports;
	UserModel? _user;

	/// The reminders data model. 
	Reminders get reminders => _reminders ??= Reminders();

	/// The schedule data model. 
	ScheduleModel get schedule => _schedule ??= ScheduleModel();

	/// The sports data model. 
	Sports get sports => _sports ??= Sports();

	/// The user data model. 
	UserModel get user => _user ??= UserModel();

	/// Whether the data models have been initialized.
	bool isReady = false;

	@override
	Future<void> init() async {
		if (isReady) {
			return;
		}
		final Crashlytics crashlytics = Services.instance.crashlytics;
		await crashlytics.log("Initializing user model");
		await user.init();
		await crashlytics.log("Initializing reminders model");
		await reminders.init();
		await crashlytics.log("Initializing schedule model");
		await schedule.init();
		await crashlytics.log("Initializing sports model");
		await sports.init();
		isReady = true;
	}

	@override
	// This object can be revived using [init].
	// ignore: must_call_super
	void dispose() {
		_schedule?.dispose();
		_reminders?.dispose();
		_sports?.dispose();
		_user?.dispose();
		// These data models have been disposed and cannot be used again
		_reminders = null;
		_schedule = null;
		_sports = null;
		_user = null;
		isReady = false;
	}
}
