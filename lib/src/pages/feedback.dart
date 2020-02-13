// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";

import "package:ramaz/widgets.dart";
import "package:ramaz/models.dart";

/// A page to submit feedback. 
class FeedbackPage extends StatelessWidget {

	@override 
	Widget build (BuildContext context) => Scaffold(
		appBar: AppBar(title: const Text ("Send Feedback")),
		body: Padding(
			padding: const EdgeInsets.symmetric(horizontal: 50),
			child: ModelListener<FeedbackModel>(
				model: () => FeedbackModel(),
				builder: (BuildContext context, FeedbackModel model, _) => Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						TextField(
							autofocus: true,
							maxLength: 500,
							onChanged: (String text) => model.message = text,
							textCapitalization: TextCapitalization.sentences,
						),
						const SizedBox(height: 20),
						CheckboxListTile(
							value: model.anonymous, 
							onChanged: (bool value) => model.anonymous = value,
							title: const Text("Make anonymous"),
							subtitle: const Text(
								"We won't be able to see your name or email. "
								"To share them with us, keep this unchecked."
							)
						),
						const SizedBox(height: 50),
						RaisedButton.icon(
							label: const Text ("Submit"),
							icon: Icon (Icons.send),
							onPressed: !model.ready 
								? null 
								: () {
									model.send();
									Navigator.of(context).pop();
								}
						)
					]
				)
			)
		)
	);
}
