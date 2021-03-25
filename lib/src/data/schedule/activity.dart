import "package:meta/meta.dart";

/// An activity for each grade. 
@immutable
class GradeActivity {
	/// The activity for freshmen.
	final Activity? freshmen;

	/// The activity for sophomores.
	final Activity? sophomores;

	/// The activity for juniors.
	final Activity? juniors;

	/// The activity for seniors.
	final Activity? seniors; 

	/// Creates a container for activities by grade. 
	const GradeActivity({
		required this.freshmen,
		required this.sophomores,
		required this.juniors,
		required this.seniors,
	});

	/// Creates a container for activities from a JSON object.
	GradeActivity.fromJson(Map<String, dynamic> json) : 
		freshmen = Activity.fromJson(Map<String, dynamic>.from(json ["freshmen"])),
		sophomores = Activity.fromJson(
			Map<String, dynamic>.from(json ["sophomores"])
		),
		juniors = Activity.fromJson(Map<String, dynamic>.from(json ["juniors"])),
		seniors = Activity.fromJson(Map<String, dynamic>.from(json ["seniors"]));

	@override 
	String toString() => 
		"Freshmen: ${freshmen.toString()}\n\n"
		"Sophomores: ${sophomores.toString()}\n\n"
		"Juniors: ${juniors.toString()}\n\n"
		"Seniors: ${seniors.toString()}";
}

/// A type of activity during the day.
enum ActivityType {
	/// When students should go to their advisories.
	/// 
	/// The app will show everyone to their advisories. 
	advisory,

	/// When students should go to a certain room.
	room,

	/// A grade activity.
	/// 
	/// Students will be shown the activities for each grade, and in the future, 
	/// students can be shown their grade's activity. 
	grade,

	/// This type of activity should not be parsed by the app.
	/// 
	/// Just shows the message associated with the action.
	misc,
}

/// An activity during a period. 
/// 
/// Students can either be directed to their advisories or to a certain room. 
/// See [ActivityType] for a description of different activities.
/// 
/// Activities can also be nested. 
@immutable
class Activity {
	/// Parses a JSON map of Activities still in JSON.
	static Map<String, Activity> getActivities(Map<String, dynamic> json) {
		final Map<String, Activity> result = {};
		for (final MapEntry<String, dynamic> entry in json.entries) {
			result [entry.key] = Activity.fromJson(
				Map<String, dynamic>.from(entry.value)
			);
		}
		return result;
	}

	/// Maps JSON string values to [ActivityType]s.
	static const Map<String, ActivityType> stringToActivityType = {
		"advisory": ActivityType.advisory,
		"room": ActivityType.room,
		"grade": ActivityType.grade,
		"misc": ActivityType.misc,
	};

	/// The type of this activity.
	final ActivityType type;

	/// A message to be displayed with this activity.
	/// 
	/// For example, this can be used to direct students to a certain room based
	/// on grade, which is better handled by the user rather than the app.
	final String message;

	/// Creates an activity.
	const Activity({
		required this.type, 
		required this.message, 
	});

	/// Creates an activity for each grade
	Activity.grade(GradeActivity gradeActivty) : 
		message = gradeActivty.toString(),
		type = ActivityType.grade;

	/// Creates an activity from a JSON object.
	factory Activity.fromJson(Map<String, dynamic> json) => json ["message"] is Map
		? Activity.grade(
			GradeActivity.fromJson(Map<String, dynamic>.from(json ["message"]))
		)
		: Activity(
			type: stringToActivityType[json ["type"]!]!,
			message: json ["message"]
		);

	@override
	String toString() {
		switch (type) {
			case ActivityType.misc: return message;
			case ActivityType.advisory: return "Advisory -- $message";
			case ActivityType.room: return message;
			default: return "Activity";
		}
	}
}
