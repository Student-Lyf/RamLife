import "dart:convert" show JsonUnsupportedObjectError;

import "package:ramaz/data.dart";

import "../unit.dart";

const Map<String, dynamic> invalidJson = {
	"This": "is",
	"very": false,
};

void main() => testSuite (
	{
		"Subject": {
			"Equality test": SubjectTester.equalityTest,
			"Factory from JSON": SubjectTester.factoryTest,
			"Parse JSON of subjects": SubjectTester.jsonTest,
		},
		"PeriodData": {
			"Equality test": PeriodDataTester.equalityTest,
			"Factory from JSON": PeriodDataTester.factoryTest,
		},
		"Period": {
			"Equality test": PeriodTester.equalityTest,
			"Name test": PeriodTester.nameTest,
			"Info test": PeriodTester.infoTest,
		},
		"Day": {
			"Equality test": DayTester.equalityTest,
			"Name test": DayTester.nameTest,
			"'n' test": DayTester.nTest,
			"Factory test": DayTester.factoryTest,
			"Calendar test": DayTester.calendarTest,
		},
	}
);

class SubjectTester {
	static const String name = "Chemistry";
	static const String teacher = "Dr. Rotenberg";
	static const Subject testSubject = Subject (
		teacher: teacher,
		name: name,
	);
	static const Map<String, dynamic> json = {
		nameKey: name,
		teacherKey: teacher
	};
	static const String nameKey = "name", teacherKey = "teacher";

	static const String name2 = "Math";
	static const String teacher2 = "Ms. Shine";
	static const Subject testSubject2 = Subject (
		teacher: teacher2,
		name: name2,
	);


	static void equalityTest() {
		compare<Subject> (
			testSubject, 
			const Subject (name: name, teacher: teacher)
		);
		compare<Subject> (
			testSubject2, 
			const Subject (name: name2, teacher: teacher2)
		);
	}

	static void factoryTest() {
		compare<Subject> (
			Subject.fromJson (json),
			testSubject
		);

		willThrow<JsonUnsupportedObjectError> (
			() => Subject.fromJson (invalidJson),
		);
	}

	static void jsonTest() {
		compare<Map<String, Subject>> (
			Subject.getSubjects (
				{
					"1": json,
					"2": <String, dynamic> {
						nameKey: name2,
						teacherKey: teacher2, 
					}
				}
			),
			<String, Subject> {
				"1": testSubject,
				"2": testSubject2
			}
		);
	}
}

class PeriodDataTester {
	static const String room = "304", id = "12345";
	static const String roomKey = "room", idKey = "id";
	static const PeriodData period = PeriodData (room: room, id: id);

	static void equalityTest() {
		compare<PeriodData> (const PeriodData (room: room, id: id), period);
	}

	static void factoryTest() {
		compare<PeriodData> (
			PeriodData.fromJson(
				const {
					roomKey: room,					
					idKey: id,
				}
			),
			period
		);
		compare<PeriodData> (PeriodData.fromJson (null), PeriodData.free);
		willThrow<AssertionError> (
			() => PeriodData.fromJson (invalidJson),
		);
	}
}

class PeriodTester {
	static const String room = "AUD", id = "LUNCH-10", periodNum = "7";
	static const String lunchName = "Lunch 10", homeroomName = "Homeroom";

	static const PeriodData periodData = PeriodData (
		room: room, 
		id: id,
	);

	static final Range range = Range.nums(8, 00, 8, 50);

	static final Period lunch = Period (
		periodData,
		time: range, 
		period: periodNum
	);

	static final Period homeroom = Period(
		PeriodData (
			room: periodData.room,  // shhh...
			id: periodData.id,
		),
		time: range,
		period: "Homeroom",
	);

	static final Period free = Period (
		PeriodData.free,
		time: range, 
		period: periodNum,
	);

	static const lunchSubject = Subject (
		name: lunchName,
		teacher: "Ms. Daschiff"
	);

	static const homeroomSubject = Subject (
		name: homeroomName,
		teacher: "Ms. Maccabee"
	);

	static void equalityTest() {
		compare<Period> (
			Period (
				periodData,
				time: range, 
				period: periodNum
			),
			lunch
		);
	}

	static void nameTest() {
		// test for: 
		// - regular
		// - non-num period
		// - no room or id
		compare<String> (
			lunch.getName(lunchSubject),
			lunchName
		);
		compare<String> (
			homeroom.getName(homeroomSubject),
			homeroomName,
		);
		compare<String> (
			free.getName(null),
			"Free period"
		);
	}

	static void infoTest() {
		compare<List<String>> (
			lunch.getInfo (lunchSubject),
			const [
				"Time: 8:00-8:50",
				"Period: $periodNum",
				"Room: $room",
				"Teacher: Ms. Daschiff",
			]
		);
		compare<List<String>> (
			homeroom.getInfo (homeroomSubject),
			const [
				"Time: 8:00-8:50",
				"Room: AUD",
				"Teacher: Ms. Maccabee",
			]
		);
		compare<List<String>> (
			free.getInfo (null),
			const [
				"Time: 8:00-8:50",
				"Period: 7",
			]
		);
	}
}

class DayTester {
	static const Map<String, dynamic> mJson = {"letter": "M"};
	static const Map<String, dynamic> nullJson = {"letter": null};
	static const Map<String, dynamic> gJson = {"letter": "G"};
	static const Letters letter = Letters.M;
	static const Special special = Special.roshChodesh;
	static Day day1 = Day (
		letter: letter,
		special: special
	);
	static Day day2 = Day (
		letter: letter,
	);
	static Day day3 = Day (
		letter: null,
	);

	static void equalityTest() {
		compare<Day> (
			Day (
				letter: letter,
				special: special
			),
			day1
		);
		compare<Day> (
			Day (
				letter: letter,
			),
			day2
		);
		compare<Day> (
			Day (
				letter: null,
			),
			day3
		);
		compareNot(day1, "HELLO");
	}

	static void nameTest() {
		compare<String> (
			day1.name,
			"M day Rosh Chodesh"
		);
		compare<String> (
			day2.name,
			"M day"
		);
		compare<String> (
			day3.name,
			null
		);
	}

	static void nTest() {
		compare<String> (day1.n, "n");
		compare<String> (day3.n, "");
		compare<String> (
			Day (letter: Letters.B).n,
			""
		);
	}

	static void factoryTest() {
		compare<Day> (
			Day.fromJson(mJson),
			day2,
		);
		compare<Day> (
			Day.fromJson (nullJson),
			day3
		);
		willThrow<ArgumentError> (
			() => Day.fromJson (gJson),
		);
		willThrow<JsonUnsupportedObjectError> (
			() => Day.fromJson (invalidJson), 
		);
	}

	static void calendarTest() {
		const Map<String, dynamic> json = {
			"1": mJson, "2": nullJson,
		};
		final DateTime now = DateTime.now();
		compare<Map<DateTime, Day>> (
			Day.getCalendar (json),
			{
				DateTime.utc (now.year, now.month, 1): day2,
				DateTime.utc (now.year, now.month, 2): day3
			},
		);
	}
}
