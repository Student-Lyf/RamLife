import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";

/// A view model to create a [Schedule].
// ignore: prefer_mixin
class ScheduleBuilderModel with ChangeNotifier {
	/// The schedule that this schedule is based on. 
	Schedule? preset;

	ScheduleBuilderModel([this.preset]) {
		usePreset(preset);
	}

	/// Numbers for the periods.
	/// 
	/// Regular periods have numbers, others (eg, homeroom and mincha) are null.
	List<Period> periods = [];
	String? _name;
	int _numPeriods = 0;

	/// The name of this schedule.
	/// 
	/// See [Schedule.name].
	String? get name => _name;
	set name (String? value) {
		_name = value;
		notifyListeners();
	}

	/// The amount of periods. 
	/// 
	/// Grows and trims [periods] as necessary. This is [Schedule.periods.length]. 
	int get numPeriods => _numPeriods;
	set numPeriods (int value) {
		if (value == 0) {
			periods.clear();
		} else if (value < numPeriods) {
			periods.removeRange(value, periods.length);
		} else if (_numPeriods == 0) {
			periods.add(
				const Period.raw(name: "1", time: Range(Time(8, 00), Time(8, 50)))
			);
		} else {
			final Range prev = periods [value - 2].time;
			periods.add(
				Period.raw(
					name: value.toString(),
					time: Range(
						Time(prev.end.hour + 1, 0), 
						Time(prev.end.hour + 2, 0)
					)
				)
			);
		}
		_numPeriods = value;
		notifyListeners();
	}

	/// Whether this schedule is ready to be built. 
	bool get ready => numPeriods > 0  
		&& periods.isNotEmpty
		&& name != null && name!.isNotEmpty 
		&& !Schedule.schedules.any((Schedule other) => other.name == name);

	/// The schedule being built. 
	Schedule get schedule => Schedule(name: name!, periods: periods);

	/// Switches out a time in [periods] with a new time. 
	void replaceTime(int index, Range range) {
		periods [index] = Period.raw(
			name: periods [index].name, 
			time: range,
		);
		notifyListeners();
	}

	/// Sets properties of this schedule based on an existing schedule. 
	/// 
	/// The schedule can then be fine-tuned afterwards. 
	void usePreset(Schedule? schedule) {
		if (schedule == null) {
			return;
		}
		preset = schedule;
		periods = List.of(schedule.periods);  // make a copy
		_name = schedule.name;
		_numPeriods = schedule.periods.length;
		notifyListeners();
	}
}
