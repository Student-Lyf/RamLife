import "package:meta/meta.dart";

import "package:firestore/helpers.dart";

import "letters.dart";

/// A class course.
/// 
/// Classes are split into courses, which hold descriptive data about the 
/// course itself. Courses are split into one or more sections, which hold
/// data specific to that section, such as the teacher or roster list. 
@immutable
class Course extends Serializable {
	/// The name of this course.
	final String name;

	/// The course ID for this class
	final String id;

	/// The teacher for this course.
	final String teacher;

	/// Creates a course. 
	const Course({
		@required this.name, 
		@required this.id, 
		@required this.teacher,
	});

	@override
	Map<String, dynamic> get json => {
		"name": name,
		"teacher": teacher,
	};
}

@immutable
/// A period in the day. 
class Period extends Serializable {
	/// THe room this period is located in.
	final String room;

	/// The section ID for this period.
	final String id;

	/// The day this period takes place.
	final Letter day;

	/// Creates a period.
	const Period({
		@required this.room, 
		@required this.id,
		@required this.day
	});

	@override
	Map<String, dynamic> get json => {
		"room": room,
		"id": id,
	};
}
