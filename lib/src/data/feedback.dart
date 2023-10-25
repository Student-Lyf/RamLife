import "types.dart";

/// Feedback from the user.
class Feedback {
	/// The message to the developer. 
	final String message;
	
	/// The user's email
	final String? email;

	/// The user's name
	final String? name;

	/// If the feedback should be anonymized. 
	final bool anonymous;
	
	/// When the feedback was submitted.
	final DateTime timestamp;

	/// A const constructor for making a [Feedback].
	/// 
	/// If [anonymous] is true, [email] and [name] must be null. 
	/// This is for privacy reasons. 
	const Feedback({
		required this.message, 
		required this.anonymous,
		required this.timestamp,
		String? email,
		String? name, 
	}) :
		email = anonymous ? null : email,
		name = anonymous ? null : name;

	/// A JSON representation of this feedback.
	Json toJson() => {
		"message": message,
		"email": email,
		"name": name,
		"anonymous": anonymous,
		"timestamp": timestamp,
	};
}
