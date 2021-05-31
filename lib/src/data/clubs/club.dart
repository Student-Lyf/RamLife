import "../contact_info.dart";
import "message.dart";

/// An after-school club. 
/// 
/// Users can "register" for clubs and get notifications on certain events. 
/// Captains can send messages and mark certain events as important. 
class Club {
	/// The name of the club. 
	final String name;

	/// The random id assigned to the club to identify it.
	final String id;

	/// Approval status of the club.
	bool? isApproved;

	/// A short description of the club. 
	final String shortDescription;

	/// A fullfull description of full description of the club.
	final String description;

	/// A URL to an image for this club. 
	final String image;

	/// A URL to a form needed to register for the club. 
	final String? formUrl;

	/// Whether a phone number is needed to join the club.
	final bool phoneNumberRequested;
	
	/// A list of members in this club. 
	final List<ContactInfo> members;

	/// A list of messages sent by the club. 
	final List<Message> messages;

	/// A list of attendance for each member of the club.
	final Map<ContactInfo, int> attendance;

	/// The captains of the club.
	final List<ContactInfo> captains;

	/// The faculty advisor for this club.
	final List<ContactInfo?> facultyAdvisor;

	/// Creates a new club.
	Club({
		required this.name,
		required this.isApproved,
		required this.id,
		required this.shortDescription,
		required this.description,
		required this.phoneNumberRequested,
		required this.captains,
		required this.facultyAdvisor,
		required this.image,
		this.formUrl,
	}) : 
		members = [],
		attendance = {},
		messages = [];
}
