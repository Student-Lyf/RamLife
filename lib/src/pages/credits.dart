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
		margin: const EdgeInsets.fromLTRB(75, 25, 75, 25),
		elevation: 3,
		child: Row(
			children: [
				Column(
					children: [ 
						Padding(
							padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
							child: Image.network(
								contributor.imageName, 
								width: 200, 
								height: 200
							),
						)
					]
				),
				Column(
					children: [
				 Text(
						contributor.name,
						style: const TextStyle(
							color: Colors.black,
							fontSize: 85,
						),
						textAlign: TextAlign.end
					),
					Text(
						"${contributor.title}, ${contributor.email}",
						style: Theme.of(context).textTheme.headline4
					),
				const SizedBox(height: 50),
				Text(
					contributor.description,
					textAlign: TextAlign.left,
					textScaleFactor: 2
				),
				const SizedBox(height: 25),
			])]
		)
	);
}

class Contributor {

	static const List<Contributor> contributors = [
		Contributor(
			name: "David T.",
			title: "Frontend",
			email: "tarrabd@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "All Hail Shadow"
		),
		Contributor(
			name: "Brayden K.",
			title: "Backend",
			email: "braydenk@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "All Hail Shadow"
		),
		Contributor(
			name: "Joshua T.",
			title: "Middleend and Apple Expert",
			email: "todesj@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "All Hail Shadow"
		),
		Contributor(
			name: "Levi L.",
			title: "Biggest Boi",
			email: "leschesl@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "All Hail Shadow"
		),
		Contributor(
			name: "Mr. Vovsha",
			title: "Cool Guy",
			email: "evovsha@ramaz.org",
			imageName: "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
			description: "All Hail Shadow"
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