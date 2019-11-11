import "dart:async";
import "package:flutter/foundation.dart" show required, ChangeNotifier;
import "package:flutter/widgets.dart" show AsyncSnapshot;

import "package:cloud_firestore/cloud_firestore.dart" as fb;

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

// ignore: prefer_mixin
class CalendarModel with ChangeNotifier {
	static const int daysInMonth = 7 * 5;
	static final int currentMonth = DateTime.now().month;


	static List<T> mapToList<T> (Map<int, T> map) {
		final List<T> result = List.filled(map.length, null);
		for (final MapEntry<int, T> entry in map.entries) {
			result [entry.key] = entry.value;
		}
		return result;
	}

	final List<Stream<fb.DocumentSnapshot>> streams = List.filled(12, null);
	final List<AsyncSnapshot<fb.DocumentSnapshot>> snapshots = 
		List.filled(12, null);
	final List<List<MapEntry<int, Day>>> data = List.filled(12, null);
	final List<int> years = List.filled(12, null);

	Iterable<MapEntry<int, Day>> getCalendar(
		int month, 
		AsyncSnapshot<fb.DocumentSnapshot> snapshot
	) {
		if (snapshots [month] == snapshot) {
			return data [month];
		}

		snapshots [month] = snapshot;
		final List<MapEntry<int, Day>> newData = getData(month);
		data [month] = newData;
		return newData;
	}

	Stream<fb.DocumentSnapshot> getStream(int index) {
		if (streams [index] != null) {
			return streams [index];
		}

		final Stream<fb.DocumentSnapshot> stream = Firestore.getCalendar(index + 1);
		streams [index] = stream;
		return stream;
	}

	int _currentYear = DateTime.now().year;
	int get currentYear => _currentYear;
	set currentYear (int year) {
		_currentYear = year;
		for (int index = 0; index < 12; index++) {
			data [index] = getData(index);
			years [index] = getYear(index, force: true);
		}
		notifyListeners();
	}

	void setDay({
		@required int month,
		@required int date,
		@required Day day,
	}) {
		if (day == null) {
			return;
		}
		final List<MapEntry<int, Day>> entries = data [month];
		final Map<int, Day> calendarAsMap = Map.fromEntries(
			entries.where(
				(MapEntry<int, Day> entry) => entry != null
			)
		);
		final List<Day> calendar = mapToList(calendarAsMap);
		calendar [date] = day;
		Firestore.saveCalendar(
			month + 1, 
			calendar.where(
				(Day day) => day != null
			).toList().asMap().map(
				(int index, Day day) => MapEntry<String, dynamic>(
					(index + 1).toString(),
					day.toJson(),
				)
			)
		);
	}

	int getYearData(int month) => currentMonth < 7 
		? (month < 7 ? currentYear - 1 : currentYear)
		: (month < 7 ? currentYear + 1 : currentYear);

	int getYear(int month, {bool force = false}) {
		if (years [month] != null && !force) {
			return years [month];
		}

		final int result = getYearData(month);
		years [month] = result;
		return result;
	}

	List<MapEntry<int, Day>> getData(int month) {
		// final List<MapEntry<int, Day>> result = [];
		final List<Day> days = Day.getCalendar(snapshots [month].data.data);
		final int selectedYear = getYear(month);
		final DateTime firstOfMonth = DateTime(selectedYear, month + 1, 1);
		final int firstDayOfWeek = firstOfMonth.weekday;
		final int weekday = firstDayOfWeek == 7
			? 0 : firstDayOfWeek - 1;
		final List<MapEntry<int, Day>> result = [
			for (int day = 0; day < weekday; day++)
				// result.add(null);
				null,
			// result.addAll(days.asMap().entries);
			...days.asMap().entries,
			for (int day = weekday + days.length; day < daysInMonth; day++)
				// result.add(null);
				null

		];
		// }
		// }
		return result;
	}
}
