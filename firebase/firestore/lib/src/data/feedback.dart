import "package:firebase_admin_interop/firebase_admin_interop.dart" as fb;
import "package:meta/meta.dart";

/// A container class for feedback messages sent by the app.
@immutable
class Feedback {
	/// The message for this feedback.
	final String message;

	/// The email of the user who sent this feedback.
	final String email;

	/// The nsme of the user who sent this feedback.
	final String name;

	/// Whether this feedback was anonymized. 
	final bool isAnonymous;

	/// When this feedback was sent. 
	final DateTime timestamp;

	/// Creates a feedback container.
	const Feedback({
		@required this.message,
		@required this.email,
		@required this.name,
		@required this.isAnonymous,
		@required this.timestamp,
	});

	/// Converts a JSON object to a [Feedback]. 
	/// 
	/// The JSON must have the following fields:
	/// 
	/// - a `message` field
	/// - an `email` field
	/// - a `name` field
	/// - a `timestamp` field (of type [fb.Timestamp])
	/// - either an `anonymous` field or a `responseConsent` field
	/// 	- if `anonymous` is present, its value is used as-is
	/// 	- otherwise, if `responseConsent` is present, it's `not` value is used
	Feedback.fromJson(Map<String, dynamic> json) : 
		message = json ["message"],
		email = json ["email"],
		name = json ["name"],
		isAnonymous = json ["anonymous"] ?? !json ["responseConsent"],
		timestamp = json ["timestamp"].toDateTime();

	@override
	String toString() => "Feedback(${isAnonymous ? 'anonymous' : '$name, $email'})"
		": $message -- $timestamp";
}
