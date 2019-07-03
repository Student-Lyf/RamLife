import "package:flutter_test/flutter_test.dart";
import "package:matcher/matcher.dart";
import "../compare.dart";

import "dart:convert" show JsonUnsupportedObjectError;

import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/times.dart" show Range;

const Map<String, dynamic> incorrectJson = {
	"This": "is",
	"very": false,
};

void main() => test_suite (
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
		}
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
		compare<Subject> (testSubject, Subject (name: name, teacher: teacher));
		compare<Subject> (testSubject2, Subject (name: name2, teacher: teacher2));

	}

	static void factoryTest() {
		compare<Subject> (
			Subject.fromJson (json),
			testSubject
		);

		compare<Subject> (Subject.fromJson (null), null);
		willThrow (
			() => Subject.fromJson (incorrectJson),
			const TypeMatcher<JsonUnsupportedObjectError>()
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
		compare<PeriodData> (PeriodData (room: room, id: id), period);
	}

	static void factoryTest() {
		compare<PeriodData> (
			PeriodData.fromJson(
				{
					roomKey: room,					
					idKey: id,
				}
			),
			period
		);
		compare<PeriodData> (PeriodData.fromJson (null), null);
		willThrow (
			() => PeriodData.fromJson (incorrectJson),
			const TypeMatcher<JsonUnsupportedObjectError>()
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

	static final Period homeroom = Period.homeroom(
		range,
		room: periodData.room,  // shhh...
		id: periodData.id,
	);

	static final Period free = Period (
		PeriodData.free(),
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
	static void equalityTest() {

	}

	static void nameTest() {

	}

	static void nTest() {

	}

	static void factoryTest() {

	}

	static void calendarTest() {

	}
}