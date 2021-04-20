import "package:flutter/material.dart";

import "package:ramaz/data.dart";

extension on TimeOfDay {
	Time get ramazTime => Time(hour, minute);

	DateTime get toDateTime => DateTime(200, 01, 01, hour, minute);
}

extension on Time {
	TimeOfDay get toFlutterTime => TimeOfDay(hour: hour, minute: minutes);
}

/// A variant of [Period] with all nullable fields. 
/// 
/// This class also helps the UI by providing data validation.
class EditablePeriod { 
	/// The text controller for this period entry.
	/// 
	/// We save the controller instead of the string value to make the workload
	/// easier on the UI side. 
  final TextEditingController controller;

  /// The time this period starts.
  /// 
  /// Equivalent to [Range.start].
  TimeOfDay? start;

  /// The time this period ends.
  /// 
  /// Equivalent to [Range.end].
  TimeOfDay? end;
  
  /// Creates an [EditablePeriod] with the period name pre-set.
  EditablePeriod({required int index}) : 
    controller = TextEditingController(text: (index + 1).toString());
  
  /// Creates an [EditablePeriod] with the properties of a [Period].
  EditablePeriod.fromPeriod(Period period) : 
  	controller = TextEditingController(text: period.name),
  	start = period.time.start.toFlutterTime,
  	end = period.time.end.toFlutterTime;

	/// The name of this period. 
  String get name => controller.text;

  /// Whether this period is ready to be saved.
  bool get isReady => name.isNotEmpty
  	&& start != null
  	&& end != null;

	/// Whether this period has an invalid time.
	/// 
	/// Invalid means anything that will trip up the normal scheduling code. 
	/// For example, a [start] that's _after_ the [end]. Also, sometimes the UI 
	/// can suggest the wrong half of the day (AM vs PM) so this catches that too.
  bool get hasInvalidTime {
  	if (start == null || end == null) {
  		return false;
  	}
  	final DateTime startDt = start!.toDateTime;
  	final DateTime endDt = end!.toDateTime;
  	return startDt.isAfter(endDt) || endDt.difference(startDt).inHours > 10;
  }

	/// Converts this into a regular [Period] object. 
	/// 
	/// [isReady] must be true, since [Period] has non-nullable fields. 
  Period get ramazPeriod => Period.raw(
  	name: name.trim(),
  	time: Range(start!.ramazTime, end!.ramazTime),
	);
  
  /// Disposes this object's [TextEditingController].
  void dispose() => controller.dispose();
}

/// A view model for the schedule builder page. 
/// 
/// This model provides [EditablePeriod]s instead of [Period]s to allow all
/// fields to be null, and also for convenient data validation. 
// ignore: prefer_mixin
class ScheduleBuilderModel with ChangeNotifier {
	/// The periods in this schedule. 
	List<EditablePeriod> periods = [
	  for (int index = 0; index < 7; index++)
	    EditablePeriod(index: index),
	];

	String _name = "";

	/// The name of this schedule.
	String get name => _name;
	set name(String value) {
		_name = value;
		notifyListeners();
	}

	/// Whether this schedule is ready to save. 
	bool get isReady => name.isNotEmpty && periods
		.every((EditablePeriod period) => period.isReady);

	/// The finished schedule. 
	/// 
	/// [isReady] must be true, since this calls [EditablePeriod.ramazPeriod].
	Schedule get schedule => Schedule(
		name: name,
		periods: [
			for (final EditablePeriod period in periods)
				period.ramazPeriod,
		]
	);

	/// Adds a period to the schedule.
	void addPeriod() {
		periods.add(EditablePeriod(index: periods.length));
		notifyListeners();
	}

	/// Removes a period from the schedule.
	void removePeriod() {
		periods.removeLast();
		notifyListeners();
	}

	/// Copies data from another schedule to this one. 
	/// 
	/// Allows the user to quickly make small changes to existing schedules. 
	void usePreset(Schedule? preset, {bool includeName = false}) {
		if (preset == null) {
			return;
		}
		periods = [
			for (final Period period in preset.periods)
				EditablePeriod.fromPeriod(period)
		];
		if (includeName) {
			_name = preset.name;
		}
		notifyListeners();
	}

	@override
	void dispose() {
		for (final EditablePeriod period in periods) {
			period.dispose();
		}
		super.dispose();
	}
}
