import "package:flutter/material.dart";

import "package:ramaz/services/firestore.dart" show sendFeedback;
import "package:ramaz/services/auth.dart" as Auth;

class FeedbackPage extends StatelessWidget {
	final TextEditingController controller = TextEditingController();

	@override Widget build (BuildContext context) => Scaffold (
		appBar: AppBar (title: Text ("Send Feedback")),
		body: Padding (
			padding: EdgeInsets.symmetric (horizontal: 50),
			child: Column (
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					TextField (
						autofocus: true,
						controller: controller,
						maxLength: 500,
						textCapitalization: TextCapitalization.sentences
					),
					SizedBox(height: 50),
					RaisedButton.icon(
						label: Text ("Submit"),
						icon: Icon (Icons.send),
						onPressed: () => submit(context),
					)
				]
			)
		)
	);

	void submit(BuildContext context) async {
		sendFeedback (
			controller.text,
			(await Auth.currentUser()).displayName
		);
		Navigator.pop(context);
	}
}
