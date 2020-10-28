import "package:meta/meta.dart";

import "../contact_info.dart";

class Message {
	ContactInfo sender;
	DateTime timestamp;
	String body;

	Message({
		@required this.sender,
		@required this.timestamp,
		@required this.body,
	});
}
