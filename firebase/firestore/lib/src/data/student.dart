import "package:meta/meta.dart";

import "package:firestore/helpers.dart";
import "package:firestore/data.dart";

@immutable
class StudentRecord {
	final String first, last, email, id;
	const StudentRecord({
		@required this.first,
		@required this.last,
		@required this.email,
		@required this.id,
	});
}

class Student extends Serializable {
	final String email, first, last, homeroom, homeroomLocation;

	final Map<Letter, List<Period>> schedule;

	Student({
		@required this.email, 
		@required this.first,
		@required this.last, 
		@required this.homeroom,
		@required this.homeroomLocation,
		@required this.schedule,
	}) {
		Period period;
		for (final List<Period> day in schedule.values) {
			for (final Period subject in day) {
				if (subject == null) {
					continue;
				} else {
					period = subject;
					break;
				}
			}
			if (period != null) {
				break;
			}
		}

		if (period == null) {
			logger.w("WARNING: Could not find a period for $email.");
		} else {
			assert(period.json.containsKey("id"), "JSON does not have id: $period");
			assert(period.json.containsKey("room"), "JSON does not have room: $period");
			assert(period.json ["id"] is String, "Invalid id: ${period.json ['id']}");
			assert(
				period.json ["room"] is String, 
				"Invalid room: ${period.json ['room']}"
			);
		}
	}

	@override
	Map<String, dynamic> get json => {
		"M": schedule [Letter.M],
		"R": schedule [Letter.R],
		"A": schedule [Letter.A],
		"B": schedule [Letter.B],
		"C": schedule [Letter.C],
		"E": schedule [Letter.E],
		"F": schedule [Letter.F],
		"homeroom": homeroom,
		"homeroom meeting room": homeroomLocation,
	};
}