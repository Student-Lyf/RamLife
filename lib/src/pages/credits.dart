import "package:flutter/material.dart";

import "package:ramaz/widgets.dart";
import "package:ramaz/data.dart";

import "drawer.dart";

/// Creates the Credits Page by iterating through each ContributorCard.
class CreditsPage extends StatelessWidget {
	/// Builds the Credits page.
	const CreditsPage();

	@override 
	Widget build (BuildContext context) => ResponsiveScaffold(
		drawer: const NavigationDrawer(),
		appBar: AppBar(title: const Text ("Credits")),
		bodyBuilder: (_) => ListView(
			children: [
				for (final Contributor contributor in Contributor.contributors)
					ContributorCard(contributor)
			]
		)
	);
}
/// A class that creates each individual Contributor's Card.
/// It creates a Row that holds the Image, and then a Column that
/// holds the rest of the information.
class ContributorCard extends StatelessWidget{
	/// contributor is a variable that must be a Contributor.
	final Contributor contributor;
	/// ContributorCard requires a Contributor to be passed.
	const ContributorCard(this.contributor);

	@override 
	Widget build (BuildContext context) => Card(
		margin: const EdgeInsets.fromLTRB(75, 15, 75, 15),
		elevation: 3,
		child: Row(
			children: [
				Padding(
					padding: const EdgeInsets.all(20),
					child: Image.network(
						contributor.imageName, 
						width: 150, 
						height: 150
					),
				),

				Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const SizedBox(height: 20),
				 		Text(
							"${contributor.name} ${contributor.gradYear}",
							textAlign: TextAlign.start,
							style: Theme.of(context).textTheme.headline3,
						),
						Text(
							"${contributor.email}",
							textAlign: TextAlign.start,
							style: Theme.of(context).textTheme.headline6
						),
						Text(
							"${contributor.title}",
							textAlign: TextAlign.start,
							style: Theme.of(context).textTheme.headline6
						),
						const SizedBox(height: 15),
						Text(
							contributor.description,
							textAlign: TextAlign.start,
							style: Theme.of(context).textTheme.subtitle1
						),
						const SizedBox(height: 20),
					]
				),
				const Spacer()
			]
		)
	);
}