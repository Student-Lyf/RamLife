import "package:meta/meta.dart";

/// The hour and minute representation of a time. 
/// 
/// This is used instead of [Flutter's TimeOfDay](https://api.flutter.dev/flutter/material/TimeOfDay-class.html)
/// to provide the `>` and `<` operators. 
@immutable
class Time {
	/// The hour in 24-hour format. 
	final int hour;

	/// The minutes. 
	final int minutes;

	/// A const constructor.
	const Time(this.hour, this.minutes);

	/// Simplifies a [DateTime] object to a [Time].
	Time.fromDateTime (DateTime date) :
		hour = date.hour, 
		minutes = date.minute;

	/// Returns a new [Time] object from JSON data.
	/// 
	/// The json must have `hour` and `minutes` fields that map to integers.
	Time.fromJson(Map<String, dynamic> json) :
		hour = json ["hour"],
		minutes = json ["minutes"];

	/// Returns this obect in JSON form
	Map<String, dynamic> toJson() => {
		"hour": hour, 
		"minutes": minutes,
	};

	@override 
	int get hashCode => toString().hashCode;

	@override
	bool operator == (dynamic other) => other.runtimeType == Time && 
		other.hour == hour && 
		other.minutes == minutes;

	/// Returns whether this [Time] is before another [Time].
	bool operator < (Time other) => hour < other.hour || 
		(hour == other.hour && minutes < other.minutes);

	/// Returns whether this [Time] is at or before another [Time].
	bool operator <= (Time other) => this < other || this == other;

	/// Returns whether this [Time] is after another [Time].
	bool operator > (Time other) => hour > other.hour ||
		(hour == other.hour && minutes > other.minutes);

	/// Returns whether this [Time] is at or after another [Time].
	bool operator >= (Time other) => this > other || this == other;

	@override 
	String toString() => 
		"${hour > 12 ? hour - 12 : hour}:${minutes.toString().padLeft(2, '0')}";
}

/// A range of times.
@immutable
class Range {
	/// When this range starts.
	final Time start;

	/// When this range ends.
	final Time end;

	/// Provides a const constructor.
	const Range (this.start, this.end);

	/// Convenience method for manually creating a range by hand.
	Range.nums (
		int startHour, 
		int startMinute, 
		int endHour, 
		int endMinute
	) : 
		start = Time (startHour, startMinute), 
		end = Time (endHour, endMinute);

	/// Returns a new [Range] from JSON data
	/// 
	/// The json must have `start` and `end` fields 
	/// that map to [Time] JSON objects.
	/// See [Time.fromJson] for more details.
	Range.fromJson(Map<String, dynamic> json) :
		start = Time.fromJson(Map<String, dynamic>.from(json ["start"])),
		end = Time.fromJson(Map<String, dynamic>.from(json ["end"]));

	/// Returns a JSON representation of this range. 
	Map<String, dynamic> toJson() => {
		"start": start.toJson(),
		"end": end.toJson(),
	};

	/// Returns whether [other] is in this range. 
	bool contains (Time other) => start <= other && other <= end;

	@override String toString() => "$start-$end";

	@override bool operator == (dynamic other) => other is Range && 
		other.start == start && other.end == end;

	@override int get hashCode => toString().hashCode;

	/// Returns whether this range is before another range.
	bool operator < (Time other) => end.hour < other.hour ||
	(
		end.hour == other.hour &&
		end.minutes < other.minutes
	);

	/// Returns whether this range is after another range.
	bool operator > (Time other) => start.hour > other.hour ||
	(
		start.hour == other.hour &&
		start.minutes > other.minutes
	);
}

