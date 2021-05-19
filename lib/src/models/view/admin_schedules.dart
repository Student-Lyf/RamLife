import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A view model for managing the schedules.
// ignore: prefer_mixin
class AdminScheduleModel with ChangeNotifier {
	/// All available schedules.
	final List<Schedule> schedules = Schedule.schedules;

	/// All schedules in JSON form.
	List<Map> get jsonSchedules => [
		for (final Schedule schedule in schedules)
			schedule.toJson()
	];

	/// Saves the schedules to the database and refreshes. 
	Future<void> saveSchedules() async {
		await Services.instance.database.calendar.setSchedules(jsonSchedules);
		Schedule.schedules = schedules;
		notifyListeners();
	}

	/// Creates a new schedule.
	Future<void> createSchedule(Schedule schedule) async {
		schedules.add(schedule);
		return saveSchedules();
	}

	/// Updates a schedule.
	Future<void> replaceSchedule(Schedule schedule) async {
		schedules
			..removeWhere((Schedule other) => other.name == schedule.name)
			..add(schedule);
		return saveSchedules();
	}

	/// Deletes a schedule
	Future<void> deleteSchedule(Schedule schedule) async {
		schedules.removeWhere((Schedule other) => other.name == schedule.name);
		return saveSchedules();
	}
}
