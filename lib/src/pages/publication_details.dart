import "package:flutter/material.dart";
import "dart:io" show File;

import "package:flutter_pdf_viewer/flutter_pdf_viewer.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

class PublicationDetailsPage extends StatelessWidget {
	final PublicationsModel model;
	final Publication publication;

	const PublicationDetailsPage({
		@required this.model,
		@required this.publication,
	});

	@override
	Widget build(BuildContext context) => ModelListener<PublicationsModel>(
		model: () => model,
		dispose: false,
		child: Hero(
			// child: Image.file(File(publication.metadata.imagePath)),
			child: Image.asset(publication.metadata.imagePath),
			tag: "publication-${publication.name}",
		),
		builder: (BuildContext context, PublicationsModel model, Widget image) => Scaffold(
			appBar: AppBar(title: Text (publication.name)),
			floatingActionButton: FloatingActionButton(
				child: Icon (Icons.file_download),
				onPressed: () => model.getMoreIssues(publication),
			),
			body: ListView(
				children: [
					image,
					SizedBox(height: 20),
					Text (publication.metadata.description, textScaleFactor: 1.25),
					SizedBox (height: 20),
					ExpansionPanelList.radio(
						children: [
							for (final PublicationIssues issues in model.getIssues(publication)) 
								ExpansionPanelRadio(
									canTapOnHeader: true,
									value: issues.toString(),
									headerBuilder: (_, __) => Text (issues.toString()),
									body: Column (
										children: [
											for (final String issue in issues.issues)
												ListTile(
													title: Text (PublicationIssues.getDate(issue)),
													trailing: Icon (Icons.keyboard_arrow_right),
													onTap: () => PdfViewer.loadFile(
														issue,
														config: ThemeChanger.of(context).brightness == Brightness.light
															? null
															: PdfViewerConfig(nightMode: true),
													)
												)
										]
									)
								)
						]
					)
				]
			)
		)
	);
}
