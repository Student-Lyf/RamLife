import "package:meta/meta.dart";

import "activity.dart";
import "special.dart";
import "subject.dart";
import "time.dart";

/// A representation of a period, independent of the time. 
/// 
/// This is needed since the time can change on any day.
/// See [Special] for when the times can change.
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
				PeriodData.fromJson(Map<String, dynamic>.from(periodJson))
	];

	/// The room the student needs to be in for this period.
	final String room;

	/// The id for this period's subject.
	/// 
	/// See the [Subject] class for more details.
	final String id;

	/// A const constructor for a [PeriodData]. 
	/// 
	/// Free periods should be represented by null and not [PeriodData].
	const PeriodData ({
		required this.room,
		required this.id
	});

	/// Returns a [PeriodData] from a JSON object.
	/// 
	/// Both `json ["room"]` and `json ["id"]` must be non-null.
	factory PeriodData.fromJson(Map<String, dynamic> json) => PeriodData(
		room: json ["room"],
		id: json ["id"]
	);

	@override 
	String toString() => "PeriodData ($id, $room)";

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
	/// 
	/// If the time is not known (ie, the schedule is [Special.modified]), 
	/// then this will be null. 
	final Range? time;

	/// A String representation of this period. 
	/// 
	/// Since a period can be a number (like 9), or a word (like "Homeroom"),
	/// String was chosen to represent both. This means that the app does not 
	/// care whether a period is a regular class or something like homeroom.
	final String period;

	/// The section ID and room for this period. 
	/// 
	/// If null, it's a free period. 
	final PeriodData? data;

	/// The activity for this period. 
	/// 
	/// This is set in [Special.activities].
	final Activity? activity;

	/// Unpacks a [PeriodData] object and returns a Period. 
	const Period({
		required this.data,
		required this.time, 
		required this.period, 
		this.activity
	});

	/// Returns a period that represents time for Mincha. 
	/// 
	/// Use this constructor to keep a consistent definition of "Mincha".
	const Period.mincha(this.time, {this.activity}) :
		data = null,
		period = "Mincha";

	/// This is only for debug purposes. Use [getName] for UI labels.
	@override 
	String toString() => "Period $period";

	@override
	int get hashCode => "$period-${data?.id ?? ''}".hashCode;
	
	@override 
	bool operator == (dynamic other) => other is Period && 
		other.time == time &&
		other.period == period && 
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
	/// If [period] is an integer and [data] is null, then it is a free period.
	/// Otherwise, if [period] is not a number, than it is returned instead.
	/// Finally, the [Subject] that corresponds to [data] will be returned.
	/// 
	/// For example: 
	/// 
	/// 1. A period with null [data] will return "Free period"
	/// 2. A period with `period == "Homeroom"` will return "Homeroom"
	/// 3. A period with `period == "3"` will return the name of the [Subject].
	String getName(Subject? subject) => int.tryParse(period) != null && isFree
		? "Free period"
		: subject?.name ?? period;

	/// Returns a list of descriptions for this period. 
	/// 
	/// The expected subject can be retrieved by looking up `data.id`.
	/// 
	/// Useful throughout the UI. This function will: 
	/// 
	/// 1. Always display the time.
	/// 2. If [period] is a number, will display the period.
	/// 3. If `data.room` is not null, will display the room.
	/// 4. If `data.id` is valid, will return the name of the [Subject].
	List <String> getInfo (Subject? subject) => [
		if (time != null) "Time: $time",
		if (int.tryParse(period) != null) "Period: $period",
		if (data != null) "Room: ${data!.room}",
		if (subject != null) "Teacher: ${subject.teacher}",
	];
}
