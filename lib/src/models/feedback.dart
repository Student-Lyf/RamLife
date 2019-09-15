import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A view model for the feedback page. 
class FeedbackModel with ChangeNotifier {
	String _message;
	bool _responseConsent = false;

	/// Whether the user is ready to submit
	/// 
	/// Is true if the [message] is non-null and not empty. 
	bool get ready => (
		message != null && message.trim().isNotEmpty
	);

	/// The message that will be sent along with the feedback.
	String get message => _message;
	set message (String value) {
		_message = value;
		notifyListeners();
	}

	/// Whether the user consents to receiving a follow-up response. 
	bool get responseConsent => _responseConsent;
	set responseConsent(bool value) {
		_responseConsent = value;
		notifyListeners();
	}

	/// Sends the feedback to Cloud Firestore. 
	/// 
	/// The feedback is anonymized unless [responseConsent] is true.
	void send() async => Firestore.sendFeedback(
		Feedback (
			message: message,
			timestamp: DateTime.now(),
			responseConsent: responseConsent,
			name: responseConsent ? await Auth.name : null,
			email: responseConsent ? await Auth.email : null,
		).toJson()
	);
}
