import "package:meta/meta.dart";

import "package:firestore/logger.dart";
import "package:firestore/serializable.dart";

class Student extends Serializable {
	final String email, first, last, homeroom, homeroomLocation;

	final List<Map<String, dynamic>> m;
	final List<Map<String, dynamic>> r;
	final List<Map<String, dynamic>> a;
	final List<Map<String, dynamic>> b;
	final List<Map<String, dynamic>> c;
	final List<Map<String, dynamic>> e;
	final List<Map<String, dynamic>> f;

	Student({
		@required this.email, 
		@required this.first,
		@required this.last, 
		@required this.homeroom,
		@required this.homeroomLocation,
		@required this.m,
		@required this.r, 
		@required this.a,
		@required this.b,
		@required this.c,
		@required this.e,
		@required this.f
	}) {
		Map<String, dynamic> period;
		for (final List<Map<String, dynamic>> day in days) {
			for (final Map<String, dynamic> subject in day) {
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
			assert(period.containsKey("id"), "JSON does not have id: $period");
			assert(period.containsKey("room"), "JSON does not have room: $period");
			assert(period ["id"] is String, "Invalid id: ${period ['id']}");
			assert(period ["room"] is String, "Invalid room: ${period ['room']}");
		}
	}

	List<List<Map<String, dynamic>>> get days => [
		m, r, a, b, c, e, f
	];

	@override
	Map<String, dynamic> get json => {
		"M": m,
		"R": r,
		"A": a,
		"B": b,
		"C": c,
		"E": e,
		"F": f,
		"homeroom": homeroom,
		"homeroom meeting room": homeroomLocation,
	};
}