import "package:meta/meta.dart";

import "package:ramaz/constants.dart";

import "activity.dart";
import "time.dart";

/// A description of the time allotment for a day. 
/// 
/// Some days require different time periods, or even periods that 
/// are skipped altogether, as well as homeroom and Mincha movements.
/// This class helps facilitate that. 
@immutable
class Special {
	/// The name of this special. 
	final String name;
	
	/// The time allotments for the periods. 
	final List<Range> periods;

	/// The indices of periods to skip. 
	/// 
	/// For example, on fast days, all lunch periods are skipped.
	/// So here, skip would be `[6, 7, 8]`, to skip 6th, 7th and 8th periods.
	final List<int> skip;

	/// The index in [periods] that represents Mincha.
	final int? mincha;
	
	/// The index in [periods] that represents homeroom.
	final int? homeroom;

	/// Maps activities to the periods.  
	final Map<String, Activity> activities;

	/// A const constructor.
	const Special (
		this.name,
		this.periods, 
		{
			this.homeroom, 
			this.mincha,
			this.skip = const [],
			this.activities = const {}
		}
	);

	/// Returns a new [Special] from a JSON value. 
	/// 
	/// The value must either be: 
	/// 
	/// - a string, in which case it should be in the [specials] list, or
	/// - a map, in which case it will be interpreted as JSON. The JSON must have: 
	/// 	- a "name" field, which should be a string. See [name].
	/// 	- a "periods" field, which should be a list of [Range] JSON objects. 
	/// 	- a "homeroom" field, which should be an integer. See [homeroom].
	/// 	- a "skip" field, which should be a list of integers. See [skip].
	factory Special.fromJson(Object value) {
		if (value is String) {
			final Special? builtInSpecial = stringToSpecial [value];
			if (builtInSpecial != null) {
				return builtInSpecial;
			} else {
				throw ArgumentError.value(
					value, 
					"Special.fromJson: value",
					"'$value' needs to be one of ${stringToSpecial.keys.join(", ")}"
				);
			}
		} else if (value is Map) {
			final Map<String, dynamic> json = Map<String, dynamic>.from(value);
			return Special (
				json ["name"],  // name
				[  // list of periods
					for (final dynamic jsonElement in json ["periods"]) 
						Range.fromJson(Map<String, dynamic>.from(jsonElement))
				],
				homeroom: json ["homeroom"],
				mincha: json ["mincha"],
				skip: List<int>.from(json ["skip"] ?? []),
				activities: Activity.getActivities(
					Map<String, dynamic>.from(json ["activities"] ?? {})
				),
			);
		} else {
			throw ArgumentError.value (
				value,  // invalid value
				"Special.fromJson: value",  // arg name
				"$value is not a valid special",  // message
			);
		}
	}

	/// Determines whether to use a Winter Friday or regular Friday schedule. 
	/// 
	/// Winter Fridays mean shorter periods, with an ultimately shorter dismissal.
	static Special getWinterFriday([DateTime? today]) {
		final DateTime date = today ?? DateTime.now();
		final int month = date.month, day = date.day;
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

	/// Compares two lists
	/// 
	/// This function is used to compare the [periods] property of two Specials. 
	static bool deepEquals<E>(List<E> a, List<E> b) => 
		a.length == b.length &&
		<int>[
			for (int index = 0; index < (a.length); index++) 
				index
		].every(
			(int index) => a [index] == b [index]
		);

	@override 
	String toString() => name;

	@override
	int get hashCode => name.hashCode;

	@override 
	bool operator == (dynamic other) => other is Special && 
		other.name == name &&
		deepEquals<Range>(other.periods, periods) &&
		deepEquals<int>(other.skip, skip) &&
		other.mincha == mincha &&
		other.homeroom == homeroom;

	/// Returns a JSON representation of this Special.
	Map<String, dynamic> toJson() => {
		"periods": [
			for (final Range period in periods) 
				period.toJson()
		],
		"skip": skip,
		"name": name,
		"mincha": mincha,
		"homeroom": homeroom,
	};

	/// The shorter schedule for the Covid-19 pandemic. 
	static const Special covid = Special(
		"COVID-19",
		[
			Range(Time(8, 30), Time(9, 15)),
			Range(Time(9, 20), Time(9, 55)),
			Range(Time(10, 00), Time(10, 45)),
			Range(Time(10, 55), Time(11, 40)), 
			Range(Time(11, 50), Time(12, 35)), 
			Range(Time(12, 35), Time(13, 05)), 
			Range(Time(13, 15), Time(14, 00)),
			Range(Time(14, 00), Time(14, 10)), 
			Range(Time(14, 20), Time(15, 05)),
			Range(Time(15, 15), Time(16, 00)),
		],
		mincha: 7,
		skip: [1, 5],
	);

	/// The [Special] for Rosh Chodesh.
	static const Special roshChodesh = Special (
		"Rosh Chodesh", 
		[
			Range(Time(8, 00), Time(9, 05)),
			Range(Time(9, 10), Time(9, 50)),
			Range(Time(9, 55), Time(10, 35)),
			Range(Time(10, 35), Time(10, 50)),
			Range(Time(10, 50), Time(11, 30)),
			Range(Time(11, 35), Time(12, 15)),
			Range(Time(12, 20), Time(12, 55)),
			Range(Time(13, 00), Time(13, 35)),
			Range(Time(13, 40), Time(14, 15)),
			Range(Time(14, 30), Time(15, 00)),
			Range(Time(15, 00), Time(15, 20)),
			Range(Time(15, 20), Time(16, 00)),
			Range(Time(16, 05), Time(16, 45)),
		],
		homeroom: 3,
		mincha: 10,
	);

	/// The [Special] for fast days. 
	static const Special fastDay = Special (
		"Tzom",
		[
			Range(Time(8, 00), Time(8, 55)),
			Range(Time(9, 00), Time(9, 35)),
			Range(Time(9, 40), Time(10, 15)),
			Range(Time(10, 20), Time(10, 55)),
			Range(Time(11, 00), Time(11, 35)),
			Range(Time(11, 40), Time(12, 15)),
			Range(Time(12, 20), Time(12, 55)),
			Range(Time(13, 00), Time(13, 35)),
			Range(Time(13, 35), Time(14, 05)),
		],
		mincha: 8,
		skip: [6, 7, 8]
	);

	/// The [Special] for Fridays. 
	static const Special friday = Special (
		"Friday",
		[
			Range(Time(8, 00), Time(8, 45)),
			Range(Time(8, 50), Time(9, 30)),
			Range(Time(9, 35), Time(10, 15)),
			Range(Time(10, 20), Time(11, 00)),
			Range(Time(11, 00), Time(11, 20)),
			Range(Time(11, 20), Time(12, 00)),
			Range(Time(12, 05), Time(12, 45)),
			Range(Time(12, 50), Time(13, 30)),
		],
		homeroom: 4
	);

	/// The [Special] for when Rosh Chodesh falls on a Friday. 
	static const Special fridayRoshChodesh = Special (
		"Friday Rosh Chodesh",
		[
			Range(Time(8, 00), Time(9, 05)),
			Range(Time(9, 10), Time(9, 45)),
			Range(Time(9, 50), Time(10, 25)),
			Range(Time(10, 30), Time(11, 05)),
			Range(Time(11, 05), Time(11, 25)),
			Range(Time(11, 25), Time(12, 00)),
			Range(Time(12, 05), Time(12, 40)),
			Range(Time(12, 45), Time(13, 20)),
		],
		homeroom: 4
	);

	/// The [Special] for a winter Friday. See [Special.getWinterFriday].
	static const Special winterFriday = Special (
		"Winter Friday",
		[
			Range(Time(8, 00), Time(8, 45)),
			Range(Time(8, 50), Time(9, 25)),
			Range(Time(9, 30), Time(10, 05)),
			Range(Time(10, 10), Time(10, 45)),
			Range(Time(10, 45), Time(11, 05)),
			Range(Time(11, 05), Time(11, 40)),
			Range(Time(11, 45), Time(12, 20)),
			Range(Time(12, 25), Time(13, 00)),
		],
		homeroom: 4
	);

	/// The [Special] for when a Rosh Chodesh falls on a Winter Friday.
	static const Special winterFridayRoshChodesh = Special (
		"Winter Friday Rosh Chodesh",
		[
			Range(Time(8, 00), Time(9, 05)),
			Range(Time(9, 10), Time(9, 40)),
			Range(Time(9, 45), Time(10, 15)),
			Range(Time(10, 20), Time(10, 50)),
			Range(Time(10, 50), Time(11, 10)),
			Range(Time(11, 10), Time(11, 40)),
			Range(Time(11, 45), Time(12, 15)),
			Range(Time(12, 20), Time(12, 50)),
		],
		homeroom: 4
	);

	/// The [Special] for when there is an assembly during Homeroom.
	static const Special amAssembly = Special (
		"AM Assembly",
		[
			Range(Time(8, 00), Time(8, 50)),
			Range(Time(8, 55), Time(9, 30)),
			Range(Time(9, 35), Time(10, 10)),
			Range(Time(10, 10), Time(11, 10)),
			Range(Time(11, 10), Time(11, 45)),
			Range(Time(11, 50), Time(12, 25)),
			Range(Time(12, 30), Time(13, 05)),
			Range(Time(13, 10), Time(13, 45)),
			Range(Time(13, 50), Time(14, 25)),
			Range(Time(14, 30), Time(15, 05)),
			Range(Time(15, 05), Time(15, 25)),
			Range(Time(15, 25), Time(16, 00)),
			Range(Time(16, 05), Time(16, 45)),
		],
		homeroom: 3,

		mincha: 10
	);

	/// The [Special] for when there is an assembly during Mincha.
	static const Special pmAssembly = Special (
		"PM Assembly",
		[
			Range(Time(8, 00), Time(8, 50)),
			Range(Time(8, 55), Time(9, 30)),
			Range(Time(9, 35), Time(10, 10)),
			Range(Time(10, 15), Time(10, 50)),
			Range(Time(10, 55), Time(11, 30)),
			Range(Time(11, 35), Time(12, 10)),
			Range(Time(12, 15), Time(12, 50)),
			Range(Time(12, 55), Time(13, 30)),
			Range(Time(13, 35), Time(14, 10)),
			Range(Time(14, 10), Time(15, 30)),
			Range(Time(15, 30), Time(16, 05)),
			Range(Time(16, 10), Time(16, 45)),
		],
		mincha: 9
	);

	/// The [Special] for Mondays and Thursdays.
	static const Special regular = Special (
		"M or R day",
		[
			Range(Time(8, 00), Time(8, 50)),
			Range(Time(8, 55), Time(9, 35)),
			Range(Time(9, 40), Time(10, 20)),
			Range(Time(10, 20), Time(10, 35)),
			Range(Time(10, 35), Time(11, 15)),
			Range(Time(11, 20), Time(12, 00)),
			Range(Time(12, 05), Time(12, 45)),
			Range(Time(12, 50), Time(13, 30)),
			Range(Time(13, 35), Time(14, 15)),
			Range(Time(14, 20), Time(15, 00)),
			Range(Time(15, 00), Time(15, 20)),
			Range(Time(15, 20), Time(16, 00)),
			Range(Time(16, 05), Time(16, 45)),
		],
		homeroom: 3,
		mincha: 10
	);

	/// The [Special] for Tuesday and Wednesday (letters A, B, and C)
	static const Special rotate = Special (
		"A, B, or C day",
		[
			Range(Time(8, 00), Time(8, 45)),
			Range(Time(8, 50), Time(9, 30)),
			Range(Time(9, 35), Time(10, 15)),
			Range(Time(10, 15), Time(10, 35)),
			Range(Time(10, 35), Time(11, 15)),
			Range(Time(11, 20), Time(12, 00)),
			Range(Time(12, 05), Time(12, 45)),
			Range(Time(12, 50), Time(13, 30)),
			Range(Time(13, 35), Time(14, 15)),
			Range(Time(14, 20), Time(15, 00)),
			Range(Time(15, 00), Time(15, 20)),
			Range(Time(15, 20), Time(16, 00)),
			Range(Time(16, 05), Time(16, 45)),
		],
		homeroom: 3,
		mincha: 10
	);

	/// The [Special] for an early dismissal.
	static const Special early = Special (
		"Early Dismissal",
		[
			Range(Time(8, 00), Time(8, 45)),
			Range(Time(8, 50), Time(9, 25)),
			Range(Time(9, 30), Time(10, 05)),
			Range(Time(10, 05), Time(10, 20)),
			Range(Time(10, 20), Time(10, 55)),
			Range(Time(11, 00), Time(11, 35)),
			Range(Time(11, 40), Time(12, 15)),
			Range(Time(12, 20), Time(12, 55)),
			Range(Time(13, 00), Time(13, 35)),
			Range(Time(13, 40), Time(14, 15)),
			Range(Time(14, 15), Time(14, 35)),
			Range(Time(14, 35), Time(15, 10)),
			Range(Time(15, 15), Time(15, 50)),
		],
		homeroom: 3,
		mincha: 10
	);

	/// A collection of all the [Special]s
	/// 
	/// Used in the UI
	static const List<Special> specials = [
		regular,
		roshChodesh,
		fastDay,
		friday,
		fridayRoshChodesh,
		winterFriday,
		winterFridayRoshChodesh,
		amAssembly,
		pmAssembly,
		rotate,
		early,
		covid, 
	];

	/// Maps the default special names to their [Special] objects
	static final Map<String, Special> stringToSpecial = Map.fromIterable(
		specials,
		key: (special) => special.name,
	);
}
