import "package:meta/meta.dart";

import "package:ramaz/constants.dart";

import "../types.dart";
import "period.dart";
import "time.dart";

/// A description of the time allotment for a day. 
/// 
/// Some days require different time periods, or even periods that 
/// are skipped altogether, as well as homeroom and Mincha movements.
/// This class helps facilitate that. 
@immutable
class Schedule {
	/// The list of schedules defined in the calendar. 
	/// 
	/// This is a rare exception where the database and data layers intermingle. 
	/// Schedules are defined by their name, but their values exist elsewhere in 
	/// the database. So, the data layer needs some lookup method in order to be 
	/// useful. Specifically, [Day.fromJson()] needs to work _somehow_.
	/// 
	/// `late` means that this value is initialized after startup, but the value 
	/// cannot be used until it is. This means that we need to be careful not to 
	/// access this value until we can be sure that the database values were 
	/// synced. Dart will throw a runtime error otherwise, so it should be fairly
	/// simple to catch problems during testing.
	static late List<Schedule> schedules;

	/// The name of this schedule. 
	final String name;
	
	/// The time allotments for the periods. 
	final List<Period> periods;

	/// A const constructor.
	const Schedule({
		required this.name,
		required this.periods, 
	});

	/// Returns a new [Schedule] from a JSON value. 
	/// 
	/// The JSON must have: 
	/// 
	/// - a "name" field, which should be a string. See [name].
	/// - a "periods" field, which should be a list of [Period] JSON objects. 
	Schedule.fromJson(Json json) :
		name = json ["name"],  // name
		periods = [  // list of periods
			for (final dynamic jsonElement in json ["periods"]) 
				Period.fromJson(jsonElement),
		];

	/// Determines whether to use a Winter Friday or regular Friday schedule. 
	/// 
	/// Winter Fridays mean shorter periods, with an ultimately shorter dismissal.
	static Schedule getWinterFriday([DateTime? today]) {
		final date = today ?? DateTime.now();
		final month = date.month;
		final day = date.day;
		if (month >= Times.schoolStart && month < Times.winterFridayMonthStart) {
			return friday;
		} else if (
			month > Times.winterFridayMonthStart ||
			month < Times.winterFridayMonthEnd
		) {
			return winterFriday;
		} else if (
			month > Times.winterFridayMonthEnd &&
			month <= Times.schoolEnd
		) {
			return friday;
		} else if (month == Times.winterFridayMonthStart) {
			return day < Times.winterFridayDayStart ? friday : winterFriday;
		} else if (month == Times.winterFridayMonthEnd) {
			return day < Times.winterFridayDayEnd ? winterFriday : friday;
		} else {
			return friday;
		}
	}

	@override 
	String toString() => name;

	@override
	int get hashCode => name.hashCode;

	@override 
	bool operator == (dynamic other) => other is Schedule && 
		other.name == name;

	/// Returns a JSON representation of this schedule.
	Json toJson() => {
		"name": name,
		"periods": [
			for (final Period period in periods) 
				period.toJson(),
		],
	};

	/// The shorter schedule for the COVID-19 pandemic. 
	static const Schedule covid = Schedule(
		name: "COVID-19",
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 30), Time(9, 15))),
			Period.raw(name: "Tefilla", time: Range(Time(9, 20), Time(9, 55))),
			Period.raw(name: "2", time: Range(Time(10, 00), Time(10, 45))),
			Period.raw(name: "3", time: Range(Time(10, 55), Time(11, 40))), 
			Period.raw(name: "4", time: Range(Time(11, 50), Time(12, 35))), 
			Period.raw(name: "Lunch", time: Range(Time(12, 35), Time(13, 05))), 
			Period.raw(name: "5", time: Range(Time(13, 15), Time(14, 00))),
			Period.raw(name: "Mincha", time: Range(Time(14, 00), Time(14, 10))), 
			Period.raw(name: "6", time: Range(Time(14, 20), Time(15, 05))),
			Period.raw(name: "7", time: Range(Time(15, 15), Time(16, 00))),
		],
	);

	/// The schedule for Rosh Chodesh.
	static const Schedule roshChodesh = Schedule(
		name: "Rosh Chodesh", 
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 00), Time(9, 05))),
			Period.raw(name: "2", time: Range(Time(9, 10), Time(9, 50))),
			Period.raw(name: "3", time: Range(Time(9, 55), Time(10, 35))),
			Period.raw(name: "Homeroom", time: Range(Time(10, 35), Time(10, 50))),
			Period.raw(name: "4", time: Range(Time(10, 50), Time(11, 30))),
			Period.raw(name: "5", time: Range(Time(11, 35), Time(12, 15))),
			Period.raw(name: "6", time: Range(Time(12, 20), Time(12, 55))),
			Period.raw(name: "7", time: Range(Time(13, 00), Time(13, 35))),
			Period.raw(name: "8", time: Range(Time(13, 40), Time(14, 15))),
			Period.raw(name: "9", time: Range(Time(14, 30), Time(15, 00))),
			Period.raw(name: "Mincha", time: Range(Time(15, 00), Time(15, 20))),
			Period.raw(name: "10", time: Range(Time(15, 20), Time(16, 00))),
			Period.raw(name: "11", time: Range(Time(16, 05), Time(16, 45))),
		],
	);

	/// The schedule for fast days. 
	static const Schedule fastDay = Schedule(
		name: "Tzom",
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 00), Time(8, 55))),
			Period.raw(name: "2", time: Range(Time(9, 00), Time(9, 35))),
			Period.raw(name: "3", time: Range(Time(9, 40), Time(10, 15))),
			Period.raw(name: "4", time: Range(Time(10, 20), Time(10, 55))),
			Period.raw(name: "5", time: Range(Time(11, 00), Time(11, 35))),
			Period.raw(name: "9", time: Range(Time(11, 40), Time(12, 15))),
			Period.raw(name: "10", time: Range(Time(12, 20), Time(12, 55))),
			Period.raw(name: "11", time: Range(Time(13, 00), Time(13, 35))),
			Period.raw(name: "Mincha", time: Range(Time(13, 35), Time(14, 05))),
		],
	);

	/// The schedule for Fridays. 
	static const Schedule friday = Schedule(
		name: "Friday",
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 00), Time(8, 45))),
			Period.raw(name: "2", time: Range(Time(8, 50), Time(9, 30))),
			Period.raw(name: "3", time: Range(Time(9, 35), Time(10, 15))),
			Period.raw(name: "4", time: Range(Time(10, 20), Time(11, 00))),
			Period.raw(name: "Homeroom", time: Range(Time(11, 00), Time(11, 20))),
			Period.raw(name: "5", time: Range(Time(11, 20), Time(12, 00))),
			Period.raw(name: "6", time: Range(Time(12, 05), Time(12, 45))),
			Period.raw(name: "7", time: Range(Time(12, 50), Time(13, 30))),
		],
	);

	/// The schedule for when Rosh Chodesh falls on a Friday. 
	static const Schedule fridayRoshChodesh = Schedule(
		name: "Friday Rosh Chodesh",
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 00), Time(9, 05))),
			Period.raw(name: "2", time: Range(Time(9, 10), Time(9, 45))),
			Period.raw(name: "3", time: Range(Time(9, 50), Time(10, 25))),
			Period.raw(name: "4", time: Range(Time(10, 30), Time(11, 05))),
			Period.raw(name: "Homeroom", time: Range(Time(11, 05), Time(11, 25))),
			Period.raw(name: "5", time: Range(Time(11, 25), Time(12, 00))),
			Period.raw(name: "6", time: Range(Time(12, 05), Time(12, 40))),
			Period.raw(name: "7", time: Range(Time(12, 45), Time(13, 20))),
		],
	);

	/// The schedule for a winter Friday. See [Schedule.getWinterFriday].
	static const Schedule winterFriday = Schedule(
		name: "Winter Friday",
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 00), Time(8, 45))),
			Period.raw(name: "2", time: Range(Time(8, 50), Time(9, 25))),
			Period.raw(name: "3", time: Range(Time(9, 30), Time(10, 05))),
			Period.raw(name: "4", time: Range(Time(10, 10), Time(10, 45))),
			Period.raw(name: "Homeroom", time: Range(Time(10, 45), Time(11, 05))),
			Period.raw(name: "5", time: Range(Time(11, 05), Time(11, 40))),
			Period.raw(name: "6", time: Range(Time(11, 45), Time(12, 20))),
			Period.raw(name: "7", time: Range(Time(12, 25), Time(13, 00))),
		],
	);

	/// The schedule for when a Rosh Chodesh falls on a Winter Friday.
	static const Schedule winterFridayRoshChodesh = Schedule(
		name: "Winter Friday Rosh Chodesh",
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 00), Time(9, 05))),
			Period.raw(name: "2", time: Range(Time(9, 10), Time(9, 40))),
			Period.raw(name: "3", time: Range(Time(9, 45), Time(10, 15))),
			Period.raw(name: "4", time: Range(Time(10, 20), Time(10, 50))),
			Period.raw(name: "Homeroom", time: Range(Time(10, 50), Time(11, 10))),
			Period.raw(name: "5", time: Range(Time(11, 10), Time(11, 40))),
			Period.raw(name: "6", time: Range(Time(11, 45), Time(12, 15))),
			Period.raw(name: "7", time: Range(Time(12, 20), Time(12, 50))),
		],
	);

	/// The schedule for when there is an assembly during Homeroom.
	static const Schedule amAssembly = Schedule(
		name: "AM Assembly",
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 00), Time(8, 50))),
			Period.raw(name: "2", time: Range(Time(8, 55), Time(9, 30))),
			Period.raw(name: "3", time: Range(Time(9, 35), Time(10, 10))),
			Period.raw(name: "Homeroom", time: Range(Time(10, 10), Time(11, 10))),
			Period.raw(name: "4", time: Range(Time(11, 10), Time(11, 45))),
			Period.raw(name: "5", time: Range(Time(11, 50), Time(12, 25))),
			Period.raw(name: "6", time: Range(Time(12, 30), Time(13, 05))),
			Period.raw(name: "7", time: Range(Time(13, 10), Time(13, 45))),
			Period.raw(name: "8", time: Range(Time(13, 50), Time(14, 25))),
			Period.raw(name: "9", time: Range(Time(14, 30), Time(15, 05))),
			Period.raw(name: "Mincha", time: Range(Time(15, 05), Time(15, 25))),
			Period.raw(name: "10", time: Range(Time(15, 25), Time(16, 00))),
			Period.raw(name: "11", time: Range(Time(16, 05), Time(16, 45))),
		],
	);
	/// The schedule for when there is an assembly during Mincha.
	static const Schedule pmAssembly = Schedule(
		name: "PM Assembly",
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 00), Time(8, 50))),
			Period.raw(name: "2", time: Range(Time(8, 55), Time(9, 30))),
			Period.raw(name: "3", time: Range(Time(9, 35), Time(10, 10))),
			Period.raw(name: "4", time: Range(Time(10, 15), Time(10, 50))),
			Period.raw(name: "5", time: Range(Time(10, 55), Time(11, 30))),
			Period.raw(name: "6", time: Range(Time(11, 35), Time(12, 10))),
			Period.raw(name: "7", time: Range(Time(12, 15), Time(12, 50))),
			Period.raw(name: "8", time: Range(Time(12, 55), Time(13, 30))),
			Period.raw(name: "9", time: Range(Time(13, 35), Time(14, 10))),
			Period.raw(name: "Mincha", time: Range(Time(14, 10), Time(15, 30))),
			Period.raw(name: "10", time: Range(Time(15, 30), Time(16, 05))),
			Period.raw(name: "11", time: Range(Time(16, 10), Time(16, 45))),
		],
	);

	/// The schedule for an early dismissal.
	static const Schedule early = Schedule(
		name: "Early Dismissal",
		periods: [
			Period.raw(name: "1", time: Range(Time(8, 00), Time(8, 45))),
			Period.raw(name: "2", time: Range(Time(8, 50), Time(9, 25))),
			Period.raw(name: "3", time: Range(Time(9, 30), Time(10, 05))),
			Period.raw(name: "Homeroom", time: Range(Time(10, 05), Time(10, 20))),
			Period.raw(name: "4", time: Range(Time(10, 20), Time(10, 55))),
			Period.raw(name: "5", time: Range(Time(11, 00), Time(11, 35))),
			Period.raw(name: "6", time: Range(Time(11, 40), Time(12, 15))),
			Period.raw(name: "7", time: Range(Time(12, 20), Time(12, 55))),
			Period.raw(name: "8", time: Range(Time(13, 00), Time(13, 35))),
			Period.raw(name: "9", time: Range(Time(13, 40), Time(14, 15))),
			Period.raw(name: "Mincha", time: Range(Time(14, 15), Time(14, 35))),
			Period.raw(name: "10", time: Range(Time(14, 35), Time(15, 10))),
			Period.raw(name: "11", time: Range(Time(15, 15), Time(15, 50))),
		],
	);
}
