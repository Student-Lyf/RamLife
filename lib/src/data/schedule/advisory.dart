import "../types.dart";
import "package:meta/meta.dart";

/// Bundles data relevant to advisory. 
/// 
/// This is not incorporated with the schedule since advisories can happen 
/// during homeroom, and are thus dependent on the day, not the user's profile. 
@immutable
class Advisory {
	/// The section ID of this advisory. 
	final String id;

	/// The room where this advisory meets. 
	final String room;

	/// Holds advisory data. 
	const Advisory({
		required this.id,
		required this.room,
	});

	/// Creates an advisory object from JSON. 
	/// 
	/// This JSON can be null, so this constructor should only be called if needed.
	Advisory.fromJson(Json json) :
		id = json ["id"],
		room = json ["room"];
}
