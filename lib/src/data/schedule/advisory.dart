import "package:meta/meta.dart";

@immutable
class Advisory {
	final String id;
	final String room;

	const Advisory({
		@required this.id,
		@required this.room,
	});

	Advisory.fromJson(Map<String, dynamic> json) :
		id = json ["id"],
		room = json ["room"];
}