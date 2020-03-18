import "package:meta/meta.dart";

import "package:firestore/serializable.dart";

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

	const Period({@required this.room, @required this.id});

	@override
	Map<String, dynamic> get json => {
		"room": room,
		"id": id,
	};
}
