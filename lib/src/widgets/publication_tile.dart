import "package:flutter/material.dart";
import "dart:io" show File;

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
					Hero(
						tag: "publication-${publication.name}",
						child: Container(
							child: Center (
								child: SizedBox(
									height: size,
									width: size,
									// child: Image.file(
									// 	File(publication.metadata.imagePath)
									// )
									child: Image.asset(publication.metadata.imagePath)
								)
							)
						)
					)
				]
			)
		)
	);
}
