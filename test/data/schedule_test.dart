import "package:flutter_test/flutter_test.dart";
import "package:matcher/matcher.dart";
import "../compare.dart";

import "dart:convert" show JsonUnsupportedObjectError;

import "package:ramaz/data/schedule.dart";

const String name = "Chemistry";
const String teacher = "Dr. Rotenberg";
const Subject testSubject = Subject (
	teacher: teacher,
	name: name,
);
const Map<String, dynamic> json = {
	nameKey: name,
	teacherKey: teacher
};
const String nameKey = "name", teacherKey = "teacher";

const String name2 = "Math";
const String teacher2 = "Ms. Shine";
const Subject testSubject2 = Subject (
	teacher: teacher2,
	name: name2,
);

void main() => group (
	"Subject class", 
	() {
		test ("Equality test", equalityTest);
		test ("Factory from JSON", factoryTest);
		test ("Parse JSON of subjects", jsonTest);
	}
);

void equalityTest() {
	compare<Subject> (testSubject, Subject (name: name, teacher: teacher));
	compare<Subject> (testSubject2, Subject (name: name2, teacher: teacher2));

}

void factoryTest() {
	compare<Subject> (
		Subject.fromJson (json),
		testSubject
	);

	compare<Subject> (Subject.fromJson (null), null);
	expect (
		() => Subject.fromJson (
			<String, dynamic> {
				"This": "is",
				"very": false,
			}
		),
		throwsA (const TypeMatcher<JsonUnsupportedObjectError>()),
	);
}

void jsonTest() {
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
