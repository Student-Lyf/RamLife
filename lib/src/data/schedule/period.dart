import "package:meta/meta.dart";

import "activity.dart";
import "schedule.dart";
import "subject.dart";
import "time.dart";

/// A representation of a period, independent of the time. 
/// 
/// This is needed since the time can change on any day.
/// See [Schedule] for how to handle different times.
@immutable
class PeriodData {
	/// Returns a list of [PeriodData] from a JSON object.
	/// 
	/// Note that some entries in the list may be null.
	/// They represent a free period in the schedule.
	/// See [PeriodData.fromJson] for more details.
	static List<PeriodData?> getList(List json) => [
		for (final dynamic periodJson in json)
			periodJson == null ? null : 
				PeriodData.fromJson(Map.from(periodJson))
	];

	/// The room the student needs to be in for this period.
	final String room;

	/// The id for this period's subject.
	/// 
	/// See the [Subject] class for more details.
	final String id;

	/// The period's name.
	final String name;

	/// The day this period occurs.
	final String dayName;

	/// A const constructor for a [PeriodData]. 
	/// 
	/// Free periods should be represented by null and not [PeriodData].
	const PeriodData ({
		required this.room,
		required this.id,
		required this.name,
		required this.dayName,
	});

	/// Returns a [PeriodData] from a JSON object.
	/// 
	/// Both `json ["room"]` and `json ["id"]` must be non-null.
	factory PeriodData.fromJson(Map json) => PeriodData(
		room: json ["room"],
		id: json ["id"],
		name: json ["name"],
		dayName: json ["dayName"],
	);

	@override 
	String toString() => "PeriodData ($id, $room, $name, $dayName)";

	@override 
	int get hashCode => "$room-$id".hashCode;

	@override 
	bool operator == (dynamic other) => other is PeriodData &&
		other.id == id &&
		other.room == room;
}

/// A representation of a period, including the time it takes place. 
/// 
/// Period objects unpack the [PeriodData] passed to them,
/// so that they alone contain all the information to represent a period.
@immutable
class Period {
	/// The time this period takes place. 
	final Range time;

	/// A String representation of this period. 
	/// 
	/// Since a period can be a number (like 9), or a word (like "Homeroom"),
	/// String was chosen to represent both. This means that the app does not 
	/// care whether a period is a regular class or something like homeroom.
	final String name;

	/// The section ID and room for this period. 
	/// 
	/// If null, it's a free period. 
	final PeriodData? data;

	/// The activity for this period. 
	final Activity? activity;

	/// Unpacks a [PeriodData] object and returns a Period. 
	const Period({
		required this.data,
		required this.time, 
		required this.name, 
		this.activity
	});

	/// A Period as represented by the calendar. 
	/// 
	/// This period is student-agnostic, so [data] is automatically null. This 
	/// constructor can be used instead of [fromJson()] to build preset schedules
	const Period.raw({
		required this.name,
		required this.time, 
		this.activity,
	}) : data = null;

	/// A Period as represented by the calendar. 
	/// 
	/// This period is student-agnostic, so [data] is automatically null.
	Period.fromJson(Map json) : 
		time = Range.fromJson(json ["time"]),
		name = json ["name"],
		data = null, 
		activity = json ["activity"] == null ? null 
			: Activity.fromJson(json ["activity"]);

	/// The JSON representation of this period.
	Map toJson() => {
		"time": time.toJson(),
		"name": name,
		"activity": activity?.toJson(),
	};

	/// Copies this period with the [PeriodData] of another. 
	/// 
	/// This is useful because [Period] objects serve a dual purpose. Their first 
	/// use is in the calendar, where they simply store data about [Range]s and 
	/// are used to determine when the periods occur. Then, this information is 
	/// merged with the user's [PeriodData] objects to create a [Period] that has
	/// access to the class the user has at a given time. 
	Period copyWith(PeriodData? data) => Period(
		name: name,
		data: data,
		time: time, 
		activity: activity,
	);

	/// This is only for debug purposes. Use [getName] for UI labels.
	@override 
	String toString() => "Period $name";

	@override
	int get hashCode => "$name-${data?.id ?? ''}".hashCode;
	
	@override 
	bool operator == (dynamic other) => other is Period && 
		other.time == time &&
		other.name == name && 
		other.data == data;

	/// Whether this is a free period. 
	bool get isFree => data == null;

	/// The section ID for this period. 
	/// 
	/// See [PeriodData.id]. 
	String? get id => data?.id;

	/// Returns a String representation of this period. 
	/// 
	/// The expected subject can be retrieved by looking up `data.id`.
	/// 
	/// If [name] is an integer and [data] is null, then it is a free period.
	/// Otherwise, if [name] is not a number, than it is returned instead.
	/// Finally, the [Subject] that corresponds to [data] will be returned.
	/// 
	/// For example: 
	/// 
	/// 1. A period with null [data] will return "Free period"
	/// 2. A period with `name == "Homeroom"` will return "Homeroom"
	/// 3. A period with `name == "3"` will return the name of the [Subject].
	String getName(Subject? subject) => int.tryParse(name) != null && isFree
		? "Free period"
		: subject?.name ?? name;

	/// Returns a list of descriptions for this period. 
	/// 
	/// The expected subject can be retrieved by looking up `data.id`.
	/// 
	/// Useful throughout the UI. This function will: 
	/// 
	/// 1. Always display the time.
	/// 2. If [name] is a number, will display the period.
	/// 3. If `data.room` is not null, will display the room.
	/// 4. If `data.id` is valid, will return the name of the [Subject].
	List <String> getInfo (Subject? subject) => [
		"Time: $time",
		if (int.tryParse(name) != null) "Period: $name",
		if (data != null) "Room: ${data!.room}",
		if (subject != null) "Teacher: ${subject.teacher}",
		if (subject?.virtualLink != null) "Zoom link: ${subject!.virtualLink}",
	];
}
