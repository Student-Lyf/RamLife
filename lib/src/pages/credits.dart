import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/widgets.dart";

import "drawer.dart";

/// Creates the Credits Page by creating [ContributorCard] for each contributor.
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
/// 
/// It creates a Row that holds the Image, and then a Column that
/// holds the rest of the information.
class ContributorCard extends StatelessWidget{
	/// The contributor this widget represents.
	final Contributor contributor;
	
	/// Creates a widget to represent a [Contributor].
	const ContributorCard(this.contributor);

	@override 
	Widget build (BuildContext context) => SizedBox(
		height: 176,
		child: Card(
		margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
		elevation: 4,
		child: Row(
			children: [
				const SizedBox(width: 16),
				Padding(
					padding: const EdgeInsets.symmetric(vertical: 16),
					child: AspectRatio(
						aspectRatio: 1, 
						child: Image.network(
							contributor.imageName, 
						),
					),
				),
				const SizedBox(width: 8),
				Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					mainAxisSize: MainAxisSize.min,
					children: [
						const SizedBox(height: 16),
				 		Text(
							"${contributor.name} ${contributor.gradYear}",
							textAlign: TextAlign.start,
							style: Theme.of(context).textTheme.headline5,
						),
						const SizedBox(height: 8),
						Text(
							"${contributor.email}",
							textAlign: TextAlign.start,
							style: Theme.of(context).textTheme.bodyText1
						),
						Text(
							"${contributor.title}",
							textAlign: TextAlign.start,
							style: Theme.of(context).textTheme.bodyText1
						),
						const Spacer(),
						Text(
							contributor.description,
							textAlign: TextAlign.start,
							style: Theme.of(context).textTheme.subtitle1
						),
						const SizedBox(height: 16),
					]
				),
			]
		))
	);
}
