import "package:meta/meta.dart";

import "package:firestore/helpers.dart";

import "letters.dart";

@immutable
class Subject extends Serializable {
	final String name, id, teacher;

	const Subject({
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
class Period extends Serializable {
	final String room, id;
	final Letter day;

	const Period({
		@required this.room, 
		@required this.id,
		this.day
	});

	@override
	Map<String, dynamic> get json => {
		"room": room,
		"id": id,
	};
}
