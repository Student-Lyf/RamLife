import "package:meta/meta.dart";

import "club.dart";
import "contact_info.dart";

enum Grade {
	freshman, 
	sophomore,
	junior,
	senior
}

class Student {
	final ContactInfo contact;
	final List<Club> clubsAttending;
	final Grade grade;

	Student({
		@required this.contact,
		@required this.clubsAttending,
		@required this.grade,
	});
}

