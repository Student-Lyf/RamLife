import "package:flutter/material.dart";

import "package:ramaz/services.dart";

class FeedbackPage extends StatefulWidget {
	@override 
	FeedbackState createState() => FeedbackState();
}

class FeedbackState extends State<FeedbackPage> {
	final TextEditingController controller = TextEditingController();
	bool ready = false;

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
						onChanged: (String text) => setState(() => 
							ready = text.trim().isNotEmpty
						), 
						maxLength: 500,
						textCapitalization: TextCapitalization.sentences
					),
					SizedBox(height: 50),
					RaisedButton.icon(
						label: Text ("Submit"),
						icon: Icon (Icons.send),
						onPressed: ready ? () => submit(context) : null
					)
				]
			)
		)
	);

	void submit(BuildContext context) async {
		Firestore.sendFeedback (
			controller.text,
			(await Auth.currentUser()).displayName
		);
		Navigator.pop(context);
	}
}
