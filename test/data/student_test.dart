import "../utils.dart";

import "dart:convert" show JsonUnsupportedObjectError;

import "package:ramaz/data/student.dart";
import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/times.dart" show Range;

const Map<String, dynamic> invalidJson = {
	"this": "is",
	"totally": false
};

void main() => test_suite (
	const {
		"Student": {
			"Equality Test": StudentTester.equalityTest,
			"Factory Test": StudentTester.factoryTest,
			"Periods Test": StudentTester.periodsTest,
			"Homeroom Test": StudentTester.homeroomTest,
		}
	}
);

class StudentTester {
	static const Map<String, dynamic> periodJson = {
		"room": "U501",
		"id": "12345"
	};
	static final List periodListJson = List.filled (11, periodJson);
	static final PeriodData period = PeriodData.fromJson (periodJson);
	static final List<PeriodData> periods = List.filled (11, period);

	static final Map<Letters, Schedule> schedule = {
		Letters.A: Schedule (periods),
		Letters.B: Schedule (periods),
		Letters.C: Schedule (periods),
		Letters.M: Schedule (periods),
		Letters.R: Schedule (periods),
		Letters.E: Schedule (periods),
		Letters.F: Schedule (periods),
	};

	static const String homeroom = "U507";

	static final Student student = Student (
		homeroom: homeroom,
		schedule: schedule
	);

	static final Map<String, dynamic> json = {
		"homeroom meeting room": homeroom,
		"A": periodListJson,
		"B": periodListJson,
		"C": periodListJson,
		"E": periodListJson,
		"F": periodListJson,
		"M": periodListJson,
		"R": periodListJson,
	};

	static final Day day = Day (letter: Letters.B);
	static final Day noSchool = Day (letter: null);

	static Map<Letters, List<PeriodData>>convert(Student student)=> 
		Map.fromEntries(
			student.schedule.entries.map<MapEntry<Letters, List<PeriodData>>>(
				(MapEntry<Letters, Schedule> entry) => MapEntry (
					entry.key,
					entry.value.periods
				)
			)
		);

	static void equalityTest() {
		compare<Student> (
			Student (homeroom: homeroom, schedule: schedule),
			student, 
		);
	}

	static void factoryTest() {
		compareDeepMaps<Letters, PeriodData> (
			convert (Student.fromJson (json)), 
			convert (student)
		);
		willThrow<JsonUnsupportedObjectError>(
			() => Student.fromJson (invalidJson)
		);
		willThrow<ArgumentError> (
			() => Student.fromJson (
				const <String, dynamic> {
					"homeroom meeting room": homeroom, 
					"A": null, 
				}
			)
		);
	}

	static void periodsTest() {
		compare<List<Period>> (
			student.getPeriods(day),
			[
				Period (
					period,
					period: "7",
					time: Range.nums (8, 00, 8, 50)
				)
			]
		);
		compare<List<Period>> (
			student.getPeriods(noSchool),
			null
		);
	}

	static void homeroomTest() {
		compare<String> (
			student.getHomeroomMeeting(day), 
			homeroom
		);
		compare<String> (
			student.getHomeroomMeeting(noSchool),
			null
		);
	}
}