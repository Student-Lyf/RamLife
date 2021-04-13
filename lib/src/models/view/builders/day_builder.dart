import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";

/// A view model for the creating a new [Day].
// ignore: prefer_mixin
class DayBuilderModel with ChangeNotifier {
	final DateTime date;

	bool _hasSchool;
	String? _name;
	Schedule? _schedule;

	/// Creates a view model for modifying a [Day].
	DayBuilderModel({required Day? day, required this.date}) : 
		_name = day?.name,
		_schedule = day?.schedule,
		_hasSchool = day != null;

	/// The name for this day. 
	String? get name => _name;
	set name (String? value) {
		_name = value;
		notifyListeners();
	}

	/// The schedule for this day. 
	Schedule? get schedule => _schedule;
	set schedule (Schedule? value) {
		if (value == null) {
			return;
		}
		_schedule = value;
		notifyListeners();
	}

	/// If this day has school. 
	bool get hasSchool => _hasSchool;
	set hasSchool(bool value) {
		_hasSchool = value;
		notifyListeners();
	}
	
	/// The day being created (in present state). 
	Day? get day => !hasSchool ? null : Day(
		name: name ?? "", 
		schedule: schedule ?? Schedule.schedules.first,
	);

	/// Whether this day is ready to be created. 
	bool get ready => name != null && schedule != null;
}
