import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

class FeedbackModel with ChangeNotifier {
	String _message;
	bool _responseConsent = false;

	bool get ready => (
		message != null && message.trim().isNotEmpty
	);

	String get message => _message;
	set message (String value) {
		_message = value;
		notifyListeners();
	}

	bool get responseConsent => _responseConsent;
	set responseConsent(bool value) {
		_responseConsent = value;
		notifyListeners();
	}

	void send() async {
		final String email = responseConsent
			? await Auth.email
			: null; 

		final String name = responseConsent
			? await Auth.name
			: null;

		final Feedback feedback = Feedback (
			responseConsent: responseConsent,
			timestamp: DateTime.now(),
			name: name,
			message: message,
			email: email,
		);

		await Firestore.sendFeedback(feedback.toJson());
	}
}
