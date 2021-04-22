import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "package:ramaz/data.dart";
import "package:ramaz/widgets.dart";

import "drawer.dart";

/// The Credits Page with a [ContributorCard] for each contributor.
class CreditsPage extends StatelessWidget {
	/// Builds the Credits page.
	const CreditsPage();

	@override 
	Widget build (BuildContext context) => ResponsiveScaffold(
		drawer: const NavigationDrawer(),
		appBar: AppBar(title: const Text ("Credits")),
		bodyBuilder: (_) => ListView(
			children: [
				for (final Contributor contributor in Contributor.contributors)
					ContributorCard(contributor)
			]
		)
	);
}

/// A class that creates each individual Contributor's Card.
/// 
/// ListTile makes the leading image too small. So, we recreate it with rows and
/// columns. The card has a Row as a child, which in turn has an image and a 
/// Column as its children. The column holds the text. Because we don't use 
/// ListTile, we have to manually specify the height of the card. 
class ContributorCard extends StatelessWidget{
	/// The contributor this widget represents.
	final Contributor contributor;
	
	/// Creates a widget to represent a [Contributor].
	const ContributorCard(this.contributor);

	@override 
	Widget build (BuildContext context) => Card(
		// vertical is 4 so that cards are separated by 8 
		margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
		elevation: 4,
		child: ResponsiveBuilder(
			builder: (_, LayoutInfo layout, __) => Container(
				height: layout.isMobile ? 200 : 150,
				padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
				child: Row(
					children: [
						AspectRatio(
							aspectRatio: 1, 
							child: Image.network(contributor.imageName),
						),
						const SizedBox(width: 8),
						Expanded(
							flex: 2,
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
							 		Text(
										"${contributor.name} ${contributor.gradYear}",
										style: Theme.of(context).textTheme.headline5,
									),
									const SizedBox(height: 4),
									Text(
										"${contributor.title}",
										style: Theme.of(context).textTheme.bodyText2,
										textScaleFactor: 1.1,
									),
									const SizedBox(height: 4),
									InkWell(
										onTap: () => launch("mailto:${contributor.email}"),
										child: Text(
											"${contributor.email}",
											textScaleFactor: 1.1,
											style: Theme.of(context).textTheme.caption!.copyWith(
												color: Colors.blue.withAlpha(200), 
											),
										),
									),
									if (!layout.isDesktop) Expanded(
										child: Align(
											alignment: Alignment.bottomLeft,
											child: Text(
												contributor.description,
												style: Theme.of(context).textTheme.subtitle1
											),
										),
									),
								]
							),
						),
						if (layout.isDesktop) ...[
							const Spacer(),
							Expanded(
								flex: 4,
								child: Text(
									contributor.description,
									style: Theme.of(context).textTheme.subtitle1
								)
							),
							const Spacer(),
						]
					]
				)
			)
		)
	);
}
