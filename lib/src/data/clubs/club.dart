import "package:meta/meta.dart";

import "../contact_info.dart";
import "message.dart";

class Club {
	final String name;
	final String shortDescription;
	final String description;
	final List<ContactInfo> captains;
	final ContactInfo facultyAdvisor;
	final String image;
	final List<ContactInfo> members;
	final List<Message> messages;
	final String formUrl;
	final bool phoneNumberRequested;
	final Map<String, int> attendance;

	Club({
		@required this.name,
		@required this.shortDescription,
		@required this.description,
		@required this.phoneNumberRequested,
		@required this.captains,
		@required this.facultyAdvisor,
		@required this.image,
		this.formUrl,
	}) : 
		members = [],
		attendance = {},
		messages = [];
}
