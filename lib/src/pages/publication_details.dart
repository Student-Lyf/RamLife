import "package:flutter/material.dart";
import "dart:io" show File;

import "package:flutter_pdf_viewer/flutter_pdf_viewer.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

class PublicationDetailsPage extends StatelessWidget {
	static const List<String> months = [
		"Jan", "Feb", "Mar", "Apr", "May", "Jun", 
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	];
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
			tag: "publication-${publication.name}",
			child: Image.file(
				File(model.storage.getImagePath(publication.name))
			),
		),
		builder: (BuildContext context, PublicationsModel model, Widget image) => Scaffold(
			appBar: AppBar(title: Text (publication.name)),
			body: RefreshIndicator(
				onRefresh: () async => model.updatePublication(publication.name),
				child: ListView(
					shrinkWrap: true,
					padding: EdgeInsets.symmetric(horizontal: 20),
					children: [
						SizedBox(height: 20),
						image,
						SizedBox(height: 20),
						Text (publication.metadata.description, textScaleFactor: 1.25),
						SizedBox(height: 20),
						ExpansionPanelList.radio(
							children: [
								for (
									MapEntry<int, Map<int, List<String>>> yearEntry
									 in publication.metadata.issuesByMonth.entries
								 ) ...[
						        for (MapEntry<int, List<String>> monthEntry in yearEntry.value.entries)
							        ExpansionPanelRadio(
			  								canTapOnHeader: true,
			  								value: "${monthEntry.key}_${yearEntry.key}",
			  								headerBuilder: (_, __) => ListTile(
			  									title: Text ("${months [monthEntry.key]} ${yearEntry.key}")
		  									),
			  								body: Column (
			  									children: [
			  										for (final String issue in monthEntry.value)
			  											ListTile(
			  												title: Text (
			  													"\t\t${months [monthEntry.key]} " + 
			  													issue.substring(
			  														issue.lastIndexOf("_") + 1,  // the date
			  														issue.length - 4,  // but not ".pdf"
		  														)
		  													),
			  												trailing: model.downloading == issue
			  													? SizedBox(
			  														width: 25, 
			  														height: 25,
			  														child: CircularProgressIndicator()
		  														)
				  												: Icon (Icons.keyboard_arrow_right),
			  												onTap: () async => PdfViewer.loadFile(
			  													await model.getIssue(publication, issue),
			  													config: ThemeChanger.of(context).brightness == Brightness.light
			  														? null
			  														: PdfViewerConfig(nightMode: true),
			  												)
			  											)
			  									]
			  								)
	  								)
									]
							]
						)
					]
				)
			)
		)
	);
}
