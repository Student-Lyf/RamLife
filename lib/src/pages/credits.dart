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
		margin: EdgeInsets.fromLTRB(75, 25, 75, 25),
		elevation: 2,
		child: Column(
			children: [
				ListTile(
					contentPadding: EdgeInsets.fromLTRB(50, 25, 50, 0),
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
				),
				const SizedBox(height: 25),
			]
		)
	);
}

class Contributor {

	static const List<Contributor> contributors = [
		Contributor(
			name: 'David T.',
			title: 'Frontend',
			email: 'tarrabd@ramaz.org',
			imageName: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
			description: 'All Hail Shadow'
		),
		Contributor(
			name: 'Brayden K.',
			title: 'Backend',
			email: 'braydenk@ramaz.org',
			imageName: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
			description: 'All Hail Shadow'
		),
		Contributor(
			name: 'Joshua T.',
			title: 'Middleend and Apple Expert',
			email: 'todesj@ramaz.org',
			imageName: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
			description: 'All Hail Shadow'
		),
		Contributor(
			name: 'Levi L.',
			title: 'Biggest Boi',
			email: 'leschesl@ramaz.org',
			imageName: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
			description: 'All Hail Shadow'
		),
		Contributor(
			name: 'Mr. Vovsha',
			title: 'Cool Guy',
			email: 'evovsha@ramaz.org',
			imageName: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
			description: 'All Hail Shadow'
		)
	];

	final String name;
	final String title;
	final String email;
	final String description;
	final String imageName;

	const Contributor({
		required this.description,
		required this.email,
		required this.name,
		required this.title,
		required this.imageName,
	});
	
}