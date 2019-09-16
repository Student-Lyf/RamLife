import "package:flutter/foundation.dart" show immutable, required;

/// Feedback from the user.
@immutable
class Feedback {
	/// The message to the developer. 
	final String message;
	
	/// The user's email
	final String email;

	/// The user's name
	final String name;

	/// Whether the user consented to a follow up with the developers. 
	final bool responseConsent;
	
	/// When the feedback was submitted.
	final DateTime timestamp;

	/// A const constructor for making a [Feedback].
	/// 
	/// If [responseConsent] is null, [email] and [name] must be null. 
	/// This is for privacy reasons. 
	const Feedback({
		@required this.message, 
		@required this.email,
		@required this.name, 
		@required this.responseConsent,
		@required this.timestamp
	}) :
		assert(
			responseConsent || (name == null && email == null),
			"If the user does not consent to a follow up response, "
			"their name and email must not be submitted."
		);

	/// A JSON representation of this feedback.
	Map<String, dynamic> toJson() => {
		"message": message,
		"email": email,
		"name": name,
		"responseConsent": responseConsent,
		"timestamp": timestamp
	};
}
