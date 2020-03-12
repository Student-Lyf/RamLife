import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";

/// A view model to create a [Special].
// ignore: prefer_mixin
class SpecialBuilderModel with ChangeNotifier {
	/// The special that this special is based on. 
	Special preset;

	/// Numbers for the periods.
	/// 
	/// Regular periods have numbers, others (eg, homeroom and mincha) are null.
	List<String> periods = [];

	List<Range> _times = [];
	List<int> _skips = [];
	String _name;
	int _numPeriods = 0, _mincha, _homeroom;

	/// The times for the periods. 
	/// 
	/// See [Special.periods]
	List<Range> get times => _times;
	set times (List<Range> value) {
		_times = List<Range>.of(value);
		notifyListeners();
	}

	/// Indices of skipped periods. 
	/// 
	/// See [Special.skip].
	List<int> get skips => _skips;
	set skips (List<int> value) {
		_skips = value;
		notifyListeners();
	}

	/// The name of this special.
	/// 
	/// See [Special.name].
	String get name => _name;
	set name (String value) {
		_name = value;
		notifyListeners();
	}

	/// The amount of periods. 
	/// 
	/// If a period is added, a [Range] is added to [times]. 
	/// In any case, [periods] is recalculated.
	/// 
	/// This is essentially `special.periods.length`. 
	int get numPeriods => _numPeriods;
	set numPeriods (int value) {
		if (value == 0) {
			times.clear();
			homeroom = null;
			mincha = null;
		}
		if (value < numPeriods) {
			times.removeRange(value, times.length);
			if (homeroom == value) {
				homeroom = null;
			}
			if (mincha == value) {
				mincha = null;
			}
		} else {
			if (_numPeriods == 0) {
				times.add(
					const Range(Time(8, 00), Time(8, 50))
				);
			} else {
				final Range prev = times [value - 2];
				times.add(
					Range(
						Time(prev.end.hour + 1, 0), 
						Time(prev.end.hour + 2, 0)
					)
				);
			}
		}
		_numPeriods = value;
		periods = getIndices();
		notifyListeners();
	}

	/// The index of mincha in [times]. 
	/// 
	/// See [Special.mincha].
	int get mincha => _mincha;
	set mincha (int value) {
		_mincha = value;
		periods = getIndices();
		notifyListeners();
	}

	/// The index of homeroom in [times].
	/// 
	/// See [Special.homeroom].
	int get homeroom => _homeroom;
	set homeroom (int value) {
		_homeroom = value;
		periods = getIndices();
		notifyListeners();
	}

	/// Whether this special is ready to be built. 
	bool get ready => numPeriods != null && 
		numPeriods > 0 && 
		times.isNotEmpty &&
		name != null && name.isNotEmpty && 
		!Special.specials.any((Special special) => special.name == name) &&
		(preset == null || special != preset);

	/// The special being built. 
	Special get special => Special(
		name, times, 
		homeroom: homeroom,
		mincha: mincha,
		skip: skips
	);

	/// Switches out a time in [times] with a new time. 
	void replaceTime(int index, Range range) {
		times [index] = range;
		notifyListeners();
	}

	/// Toggle whether a period is skipped. 
	void toggleSkip(int index) {
		skips.contains(index)
			? skips.remove(index)
			: skips.add(index);
		notifyListeners();
	}

	/// Sets properties of this special based on an existing special. 
	/// 
	/// The special can then be fine-tuned afterwards. 
	void usePreset(Special special) {
		if (special == null) {
			return;
		}
		preset = special;
		_times = List.of(special.periods);
		_skips = special.skip ?? [];
		_name = special.name;
		_numPeriods = special.periods.length;
		_mincha = special.mincha;
		_homeroom = special.homeroom;
		periods = getIndices();
		notifyListeners();
	}

	/// Gets the period numbers for all periods. 
	/// 
	/// Any non-normal periods (eg, homeroom) are represented by `null`
	List<String> getIndices() {
		int counter = 1;
		return [
			for (int index = 0; index < _times.length; index++)
				if (index == homeroom)
					"homeroom"
				else if (index == mincha)
					"Mincha"
				else
					(counter++).toString()
		];
	}
}
