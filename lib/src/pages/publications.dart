import "package:flutter/material.dart";

import "drawer.dart";
import "publication_details.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

class PublicationsPage extends StatelessWidget {
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
			builder: (BuildContext context, PublicationsModel model, _) => model.publications.isEmpty 
				?	Center(child: CircularProgressIndicator())
				: RefreshIndicator(
					onRefresh: model.updatePublications,
					child: ListView(
						itemExtent: 250,
						children: [
							for (final Publication publication in model.publications)
								PublicationTile(
									publication: publication,
									onTap: () => Navigator.of(context).push(
										MaterialPageRoute(
											builder: (_) => PublicationDetailsPage(
												publication: publication,
												model: model,
											),
										),
									),
								),
						]
					)
				)
		)
	);
}
