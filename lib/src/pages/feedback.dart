import "package:flutter/material.dart";

import "package:ramaz/widgets.dart";
import "package:ramaz/models.dart";

class FeedbackPage extends StatelessWidget {
	// ignore_for_file: prefer_const_constructors_in_immutables

	@override 
	Widget build (BuildContext context) => Scaffold (
		appBar: AppBar (title: const Text ("Send Feedback")),
		body: Padding (
			padding: const EdgeInsets.symmetric (horizontal: 50),
			child: ModelListener<FeedbackModel>(
				model: () => FeedbackModel(),
				builder: (BuildContext context, FeedbackModel model, _) => Column (
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						TextField (
							autofocus: true,
							maxLength: 500,
							onChanged: (String text) => model.message = text,
							textCapitalization: TextCapitalization.sentences,
						),
						const SizedBox(height: 20),
						CheckboxListTile(
							value: model.responseConsent, 
							onChanged: (bool value) => model.responseConsent = value,
							title: const Text ("Get follow-up"),
							subtitle: const Text ("We may follow up with you for more details")
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
