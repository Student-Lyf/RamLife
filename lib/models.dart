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
/// 
library models;

// data models
export "src/models/data/admin.dart";
export "src/models/data/reminders.dart";
export "src/models/data/schedule.dart";

// view models
export "src/models/view/feedback.dart";
export "src/models/view/reminder_builder.dart";
export "src/models/view/schedule.dart";
