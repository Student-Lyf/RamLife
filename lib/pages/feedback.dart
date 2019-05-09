import "package:flutter/material.dart";

import "package:ramaz/pages/drawer.dart" show NavigationDrawer;

class FeedbackPage extends StatelessWidget {
	final TextEditingController controller = TextEditingController();

	@override Widget build (BuildContext context) => Scaffold (
		appBar: AppBar (title: Text ("Send Feedback")),
		drawer: NavigationDrawer(),
		body: Padding (
			padding: EdgeInsets.symmetric (horizontal: 50),
			child: Column (
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					// SizedBox (height: 50),
					Center (
						child: TextField (
							autofocus: true,
							controller: controller,
							maxLength: 500,
						)
					),
					SizedBox(height: 50),
					RaisedButton.icon(
						label: Text ("Submit"),
						icon: Icon (Icons.send),
						onPressed: submit,
					)
				]
			)
		)
	);

	void submit() {
		final String feedback = controller.text;
		print (feedback);
	}
}