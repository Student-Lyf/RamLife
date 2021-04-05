// ignore_for_file: prefer_const_constructors_in_immutables
import "package:flutter/material.dart";

import "package:ramaz/widgets.dart";
import "package:ramaz/models.dart";

import "drawer.dart";

/// A page to submit feedback. 
class FeedbackPage extends StatelessWidget {
	@override 
	Widget build (BuildContext context) => ResponsiveScaffold(
		drawer: const NavigationDrawer(),
		appBar: AppBar(title: const Text ("Send Feedback")),
		bodyBuilder: (_) => ModelListener<FeedbackModel>(
			model: () => FeedbackModel(),
			builder: (BuildContext context, FeedbackModel model, _) => Center(
				child: SizedBox(
					width: 400, 
					child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.center,
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
						// If tristate == false (default), value != null
						onChanged: (bool? value) => model.anonymous = value!,
						title: const Text("Anonymous"),
						subtitle: const Text(
							"To keep your name and email hidden, check this box."
						)
					),
					const SizedBox(height: 50),
					ElevatedButton.icon(
						label: const Text ("Submit"),
						icon: const Icon(Icons.send),
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
		))
	);
}
