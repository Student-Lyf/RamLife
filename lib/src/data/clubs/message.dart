import "../contact_info.dart";

/// A message in a message board. 
/// 
/// This is meant for the clubs feature, but can be used anywhere.
class Message {
	/// Who sent this message. 
	ContactInfo sender;

	/// When this message was sent.
	DateTime timestamp;

	/// The content of this message. 
	String body;

	/// Creates a new message. 
	Message({
		required this.sender,
		required this.timestamp,
		required this.body,
	});
}
