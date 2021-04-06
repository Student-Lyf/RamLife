import "package:flutter/foundation.dart" show ChangeNotifier;

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

/// A view model for the creating a new [Day].
// ignore: prefer_mixin
class DayBuilderModel with ChangeNotifier {
	final DateTime date;

	bool _hasSchool;
	String? _name;
	Special? _special;

	/// Creates a view model for modifying a [Day].
	DayBuilderModel({required Day? day, required this.date}) : 
		_name = day?.name,
		_special = day?.special,
		_hasSchool = day != null;

	/// The name for this day. 
	String? get name => _name;
	set name (String? value) {
		_name = value;
		notifyListeners();
	}

	/// The special for this day. 
	Special? get special => _special;
	set special (Special? value) {
		if (value == null) {
			return;
		}
		_special = value;
		notifyListeners();
	}

	/// If this day has school. 
	bool get hasSchool => _hasSchool;
	set hasSchool(bool value) {
		_hasSchool = value;
		notifyListeners();
	}
	
	/// The day being created (in present state). 
	/// 
	/// The model uses [name] and [special]. 
	Day? get day => !hasSchool ? null : Day(
		name: name ?? "", 
		special: special ?? presetSpecials.first,
	);

	/// The built-in specials.  
	List<Special> get presetSpecials => Special.specials;

	/// Custom user-created specials. 
	List<Special> get userSpecials => Models.instance.user.admin!.specials;

	/// Whether this day is ready to be created. 
	bool get ready => name != null && special != null;
}
