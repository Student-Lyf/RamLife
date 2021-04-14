import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

// ignore: prefer_mixin
class AdminScheduleModel with ChangeNotifier {
	final List<Schedule> schedules = Schedule.schedules;

	List<Map> get jsonSchedules => [
		for (final Schedule schedule in schedules)
			schedule.toJson()
	];

	Future<void> saveSchedules() async {
		await Services.instance.database.saveSchedules(jsonSchedules);
		Schedule.schedules = schedules;
		notifyListeners();
	}

	Future<void> createSchedule(Schedule schedule) async {
		schedules.add(schedule);
		return saveSchedules();
	}

	Future<void> deleteSchedule(Schedule schedule) async {
		schedules.removeWhere(
			(Schedule other) => other.name == schedule.name
		);
		return saveSchedules();
	}
}
