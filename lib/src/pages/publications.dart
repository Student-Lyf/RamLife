import "package:flutter/material.dart";

import "drawer.dart";
import "publication_details.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

class PublicationsPage extends StatelessWidget {
	static const Publication pub = Publication(
		name: "RamPage",
		issues: ["path/blah/blah/2019_05_22.pdf", "path/blah/blah/2019_05_21.pdf", "path/blah/blah/2018_02_27.pdf"],
		metadata: PublicationMetadata(
			imagePath: "images/logos/ramaz/ram_square_words.png",
			allIssues: ["path/blah/blah/2019_05_22.pdf", "path/blah/blah/2019_05_21.pdf", "path/blah/blah/2018_02_27.pdf"],
			recents: ["path/blah/blah/2019_05_22.pdf", "path/blah/blah/2019_05_21.pdf", "path/blah/blah/2018_02_27.pdf"],
			description: "The Rampage newspaper is very prestigous blah blah blah blah blah blah blah blah blah blah blah blah blah blah",
		)
	);

	@override
	Widget build(BuildContext context) => Scaffold(
		drawer: NavigationDrawer(),
		bottomNavigationBar: Footer(),
		appBar: AppBar(
			title: Text ("Publications"),
			actions: [
				IconButton(
					icon: Icon(Icons.home),
					onPressed: () => Navigator.of(context).pushReplacementNamed(Routes.HOME),
				)
			]
		),
		body: ModelListener(
			model: () => PublicationsModel(Services.of(context).services),
			builder: (BuildContext context, PublicationsModel model, _) => ListView(
				children: [
					PublicationTile(
						onTap: () => Navigator.of(context).push(
							MaterialPageRoute(
								builder: (_) => PublicationDetailsPage(
									publication: pub,
									model: model,
								),
							),
						),
						publication: pub,
					),
					for (final Publication publication in model.publications) 
						PublicationTile(
							publication: publication,
							onTap: null,
						),
				]
			)
		)
	);
}
