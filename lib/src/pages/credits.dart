import "package:flutter/material.dart";

import "drawer.dart";

class CreditsPage extends StatelessWidget {

	const CreditsPage();

	@override 
	Widget build (BuildContext context) => Scaffold(
		drawer: const NavigationDrawer(),
		appBar: AppBar(title: const Text ("Credits")),
		body: ListView(
			children: [
				for (final Contributor contributor in Contributor.contributors)
					ContributorCard(contributor)
			]
		)
	);
}

class ContributorCard extends StatelessWidget{
	final Contributor contributor;

	const ContributorCard(this.contributor);

	@override 
	Widget build (BuildContext context) => Card(
		child: Column(
			children: [
				ListTile(
					leading: Image.network(contributor.imageName),
					title: Text(
						contributor.name,
						style: Theme.of(context).textTheme.headline4
					),
					subtitle: Text(
						"${contributor.title}, ${contributor.email}",
						textScaleFactor: 1.5
					)
				),
				const SizedBox(height: 50),
				Text(
					contributor.description,
					textAlign: TextAlign.left,
					textScaleFactor: 1.2
				)
			]
		)
	);
}

class Contributor {

	static const List<Contributor> contributors = [
	Contributor(

	)
	];




	final String name;
	final String title;
	final String email;
	final String description;
	final double imgSideLength;
	final String imageName;

	const Contributor({
		required this.description,
		required this.email,
		required this.name,
		required this.title,
		required this.imgSideLength,
		required this.imageName,
	});
}