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
	static List<PeriodData> getList(List json) => [
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
	/// If both [id] and [room] are null, then it is a free period.
	/// Use [PeriodData.free] instead. Otherwise, it is considered an error
	/// to have a null [room] OR [id].
	const PeriodData ({
		@required this.room,
		@required this.id
	}) : 
		assert (
			room != null || id != null,
			"Room and id must both be null or not."
		);

	const PeriodData._free() : 
		room = null,
		id = null;

	/// A free period.
	/// 
	/// Use this instead of manually constructing a [PeriodData] 
	/// to keep consistency throughout the code. 
	static const free = PeriodData._free();

	/// Returns a [PeriodData] from a JSON object.
	/// 
	/// If the JSON object is null, then it is considered a free period.
	/// Otherwise, both `json ["room"]` and `json ["id"]` must be non-null.
	factory PeriodData.fromJson (Map<String, dynamic> json) => json == null
		? PeriodData.free
		: PeriodData(
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
	final Range time;

	/// The room this period is in.
	/// 
	/// It may be null, indicating that the student is not expected to be in class.
	/// 
	/// Since the room comes from a [PeriodData] object, both the room and [id] 
	/// must both be null, or both must be non-null. See [PeriodData()] for more.
	final String room; 

	/// A String representation of this period. 
	/// 
	/// Since a period can be a number (like 9), or a word (like "Homeroom"),
	/// String was chosen to represent both. This means that the app does not 
	/// care whether a period is a regular class or something like homeroom.
	final String period;

	/// The id of the [Subject] for this period. 
	/// 
	/// It may be null, indicating that the student is not expected 
	/// to be in a class at this time. 
	/// 
	/// Since the id comes from a [PeriodData] object, both the id and [room] 
	/// must both be null, or both must be non-null. See [PeriodData()] for more.
	final String id;

	/// The activity for this period. 
	/// 
	/// This is set in [Special.activities].
	final Activity activity;

	/// Unpacks a [PeriodData] object and returns a Period. 
	Period(
		PeriodData data,
		{@required this.time, @required this.period, @required this.activity}
	) : 
		room = data.room,
		id = data.id;

	/// Returns a period that represents time for Mincha. 
	/// 
	/// Use this constructor to keep a consistent definition of "Mincha".
	const Period.mincha(this.time, {this.activity}) :
		room = null,
		id = null,
		period = "Mincha";

	/// This is only for debug purposes. Use [getName] for UI labels.
	@override 
	String toString() => "Period $period";

	@override
	int get hashCode => "$period-$id".hashCode;
	
	@override 
	bool operator == (dynamic other) => other is Period && 
		other.time == time &&
		other.room == room && 
		other.period == period && 
		other.id == id;

	/// Returns a String representation of this period. 
	/// 
	/// The expected subject can be retrieved by looking up the [id].
	/// 
	/// If [period] is an integer and [id] is null, then it is a free period.
	/// Otherwise, if [period] is not a number, than it is returned instead.
	/// Finally, the [Subject] that corresponds to [id] will be returned.
	/// 
	/// For example: 
	/// 
	/// 1. A period with [PeriodData.free] will return "Free period"
	/// 2. A period with `period == "Homeroom"` will return "Homeroom"
	/// 3. A period with `period == "3"` will return the name of the [Subject].
	/// 
	String getName(Subject subject) => int.tryParse(period) != null && id == null
		? "Free period"
		: subject?.name ?? period;

	/// Returns a list of descriptions for this period. 
	/// 
	/// The expected subject can be retrieved by looking up the [id].
	/// 
	/// Useful throughout the UI. This function will: 
	/// 
	/// 1. Always display the time.
	/// 2. If [period] is a number, will display the period.
	/// 3. If [room] is not null, will display the room.
	/// 4. If [id] is valid, will return the name of the [Subject].
	/// 
	List <String> getInfo (Subject subject) => [
		if (time != null) "Time: $time",
		if (int.tryParse(period) != null) "Period: $period",
		if (room != null) "Room: $room",
		if (subject != null) "Teacher: ${subject.teacher}",
	];
}

