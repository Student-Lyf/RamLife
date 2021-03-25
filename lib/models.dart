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
export "src/models/view/builders/day_builder.dart";
export "src/models/view/builders/reminder_builder.dart";
export "src/models/view/builders/special_builder.dart";
export "src/models/view/builders/sports_builder.dart";
export "src/models/view/calendar_editor.dart";
export "src/models/view/feedback.dart";
export "src/models/view/home.dart";
export "src/models/view/schedule.dart";
export "src/models/view/sports.dart";

/// Bundles all the data models together. 
/// 
/// Each data model is responsible for different types of data. For example,
/// [Schedule] keeps track of the schedule (as well as associated data such as
/// the current period) and [UserModel] reads the user data. 
/// 
/// Each data model inherits from [Model], so it has [init] and [dispose] 
/// functions. This model serves to bundles those together, so that calling
/// [init] or [dispose] on this model will call the respective functions 
/// on all the data models. 
class Models extends Model {
	/// The singleton instance of this class.
	static Models instance = Models();

	/// The reminders data model. 
	Reminders reminders = Reminders();

	/// The schedule data model. 
	Schedule schedule = Schedule();

	/// The sports data model. 
	Sports sports = Sports();

	/// The user data model. 
	UserModel user = UserModel();

	/// Whether the data models have been initialized.
	bool isReady = false;

	@override
	Future<void> init() async {
		await user.init();
		await reminders.init();
		await schedule.init();
		await sports.init(refresh: true);
		isReady = true;
	}

	@override
	// This object can be revived using [init].
	// ignore: must_call_super
	void dispose() {
		schedule.dispose();
		reminders.dispose();
		sports.dispose();
		user.dispose();
		isReady = false;
	}
}
