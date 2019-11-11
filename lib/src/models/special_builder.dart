import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";

// ignore: prefer_mixin
class SpecialBuilderModel with ChangeNotifier {
	Special preset;
	List<Range> _times = [];
	List<int> _skips = [];
	String _name;
	int _numPeriods = 0, _mincha, _homeroom;
	List<int> indices = [];

	List<Range> get times => _times;
	set times (List<Range> value) {
		_times = value;
		notifyListeners();
	}

	List<int> get skips => _skips;
	set skips (List<int> value) {
		_skips = value;
		notifyListeners();
	}

	String get name => _name;
	set name (String value) {
		_name = value;
		notifyListeners();
	}

	int get numPeriods => _numPeriods;
	set numPeriods (int value) {
		if (value < numPeriods) {
			times.removeRange(value, times.length);
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
		indices = getIndices();
		notifyListeners();
	}

	int get mincha => _mincha;
	set mincha (int value) {
		_mincha = value;
		indices = getIndices();
		notifyListeners();
	}

	int get homeroom => _homeroom;
	set homeroom (int value) {
		_homeroom = value;
		indices = getIndices();
		notifyListeners();
	}

	bool get ready => numPeriods != null && 
		numPeriods > 0 && 
		times.isNotEmpty &&
		name != null && name.isNotEmpty &&
		(preset == null || special != preset);

	Special get special => Special(
		name, times, 
		homeroom: homeroom,
		mincha: mincha,
		skip: skips
	);

	void replaceTime(int index, Range range) {
		times [index] = range;
		notifyListeners();
	}

	void toggleSkip(int index) {
		skips.contains(index)
			? skips.remove(index)
			: skips.add(index);
		notifyListeners();
	}

	void usePreset(Special special) {
		if (special == null) {
			return;
		}
		preset = special;
		_times = special.periods;
		_skips = special.skip ?? [];
		_name = special.name;
		_numPeriods = special.periods.length;
		_mincha = special.mincha;
		_homeroom = special.homeroom;
		indices = getIndices();
		notifyListeners();
	}

	List<int> getIndices() {
		final List<int> result = [];
		int counter = 1;
		for (int index = 0; index < _times.length; index++) {
			result.add(homeroom == index || mincha == index ? null : counter++);
		}
		return result;
	}
}
