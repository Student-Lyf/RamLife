import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";  

// ignore: directives_ordering
import "package:ramaz/data.dart";
import "package:ramaz/widgets.dart";

import "drawer.dart";

/// The Credits Page with a [ResponsiveContributorCard] for each contributor.
class CreditsPage extends StatelessWidget {
	/// Builds the Credits page.
	const CreditsPage();

	@override 
	Widget build (BuildContext context) => ResponsiveScaffold(
		drawer: const RamlifeDrawer(),
		appBar: AppBar(title: const Text ("Credits")),
		body: ListView(
			children: [
				const SizedBox(height: 8),
				Text(
					"Thank You", 
					style: Theme.of(context).textTheme.headlineMedium,
					textAlign: TextAlign.center,
				),
				Text(
					"To those who made this app possible",
					style: Theme.of(context).textTheme.headlineSmall,
					textAlign: TextAlign.center,
				),
				const SizedBox(height: 16),
				for (final Contributor contributor in Contributor.contributors)
					ResponsiveContributorCard(contributor)
			]
		)
	);
}

/// A class that shows info about each contributor.
/// 
/// This widget shows a [CompactContributorCard] for small screens
/// and [WideContributorCard] on larger screens.
class ResponsiveContributorCard extends StatelessWidget{
	/// The contributor this widget represents.
	final Contributor contributor;
	
	/// Creates a widget to represent a [Contributor].
	const ResponsiveContributorCard(this.contributor);

	@override 
	Widget build(BuildContext context) => Card(
		// vertical is 4 so that cards are separated by 8 
		margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
		elevation: 4,
		child: ResponsiveBuilder(
			builder: (_, LayoutInfo layout, __) => layout.isMobile
				? CompactContributorCard(contributor)
				: WideContributorCard(contributor),
		)
	);
}

/// A wide variant of the contributor card. 
class WideContributorCard extends StatelessWidget {
	/// The height of the card.
	/// 
	/// This widget is made of rows and columns instead of a ListTile. As such, we 
	/// have to manually specify the height, or else it will be unbounded. 
	static const double height = 150;

	/// The contributor shown by this card.
	final Contributor contributor;

	/// Creates a wide contributor card. 
	const WideContributorCard(this.contributor);

	@override
	Widget build(BuildContext context) => Container(
		height: height,
		padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
		child: Row(
			children: [
				Flexible(
					flex: 1,
					child: AspectRatio(
						aspectRatio: 1, 
						child: Image.asset(contributor.imageName),
					),
				),
				const SizedBox(width: 8),
				Expanded(
					flex: 3,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
					 		Text(
								"${contributor.name} ${contributor.gradYear}",
								style: Theme.of(context).textTheme.headlineSmall,
							),
							const SizedBox(height: 4),
							Text(
								contributor.title,
								style: Theme.of(context).textTheme.bodyMedium,
								textScaleFactor: 1.1,
							),
							const SizedBox(height: 4),
							InkWell(
								onTap: () => launchUrl(Uri.parse(contributor.url)),
								child: Text(
									contributor.linkName,
									textScaleFactor: 1.1,
									style: Theme.of(context).textTheme.bodySmall!.copyWith(
										color: Colors.blue.withAlpha(200), 
									),
								),
							),
						]
					),
				),
				const Spacer(),
				Expanded(
					flex: 3,
					child: Text(
						contributor.description,
						style: Theme.of(context).textTheme.titleMedium
					)
				),
				const Spacer(),
			]
		)
	);
}

/// A compact variant of the contributor card. 
class CompactContributorCard extends StatelessWidget {
	/// The contributor being represented.
	final Contributor contributor;

	/// Creates a compact contributor card.
	const CompactContributorCard(this.contributor);

	@override
	Widget build(BuildContext context) => Column(
		children: [
			ListTile(
				visualDensity: const VisualDensity(vertical: 3),
				title: Text("${contributor.name} ${contributor.gradYear}"),
				leading: CircleAvatar(
					radius: 48,  // a standard Material radius
					backgroundImage: AssetImage(contributor.imageName),
				),
				subtitle: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text(contributor.title),
						InkWell(
							onTap: () => launchUrl(Uri.parse(contributor.url)),
							child: Text(
								contributor.linkName,
								style: TextStyle(color: Colors.blue.withAlpha(200)),
							),
						),
					]
				),
			),
			Padding(
				padding: const EdgeInsets.all(16),
				child: Text(contributor.description),
			),
		]
	);
}
