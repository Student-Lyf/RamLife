/// This library handles storing all the data in the app. 
/// 
/// This library contains dataclasses to store and serialize data.
/// The dataclasses have logical properties and methods in order
/// to abstract business logic from the rest of the application.
/// 
/// In other words, any logic that separates this app from any 
/// other app should be implemented in this library.
library data;

export "src/data/admin.dart";

// The clubs feature
export "src/data/clubs/club.dart";
export "src/data/clubs/message.dart";

export "src/data/feedback.dart";
export "src/data/reminder.dart";

// The schedule feature
export "src/data/schedule/activity.dart";
export "src/data/schedule/advisory.dart";
export "src/data/schedule/day.dart";
export "src/data/schedule/period.dart";
export "src/data/schedule/special.dart";
export "src/data/schedule/subject.dart";
export "src/data/schedule/time.dart";

export "src/data/sports.dart";
export "src/data/user.dart";
