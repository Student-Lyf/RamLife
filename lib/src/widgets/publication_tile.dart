import "package:flutter/material.dart";
import "dart:io" show File;

import "services.dart";

import "package:ramaz/data.dart";

class PublicationTile extends StatelessWidget {
	static const double size = 150;

	final Publication publication;
	final VoidCallback onTap;

	const PublicationTile({
		@required this.publication, 
		@required this.onTap
	});

	@override
	Widget build(BuildContext context) => Card(
		child: InkWell(
			onTap: onTap,
			child: Column (
				children: [
					ListTile(title: Text (publication.name)),
					SizedBox(
						height: size,
						width: size,
						child: Hero(
							tag: "publication-${publication.name}",
							child: Center (
								child: Image.file(
									File(
										Services
											.of(context)
											.storage
											.getImagePath(publication.name)
									)
								)
							)
						)
					)
				]
			)
		)
	);
}
