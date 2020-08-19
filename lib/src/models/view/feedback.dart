import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A view model for the feedback page. 
// ignore: prefer_mixin
class FeedbackModel with ChangeNotifier {
	String _message;
	bool _anonymous = true;

	/// Whether the user is ready to submit
	/// 
	/// Is true if the [message] is non-null and not empty. 
	bool get ready => message != null && message.trim().isNotEmpty;

	/// The message that will be sent along with the feedback.
	String get message => _message;
	set message (String value) {
		_message = value;
		notifyListeners();
	}

	/// Whether the user consents to receiving a follow-up response. 
	bool get anonymous => _anonymous;
	set anonymous(bool value) {
		_anonymous = value;
		notifyListeners();
	}

	/// Sends the feedback to Cloud Firestore. 
	/// 
	/// The feedback is anonymized if [anonymous] is true.
	Future<void> send() async => Database.sendFeedback(
		Feedback (
			message: message,
			timestamp: DateTime.now(),
			anonymous: anonymous,
			name: anonymous ? null : Auth.name,
			email: anonymous ? null : Auth.email,
		).toJson()
	);
}
