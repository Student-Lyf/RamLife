import "package:flutter/material.dart";

/// A tile to represent some info. 
/// 
/// This widget can be used by other widgets as a base. It  builds a [Card]
/// with a [ListTile] as a child. [icon] is passed as [ListTile.leading], 
/// [title] is passed to [ListTile.title], [children] is unpacked into 
/// [ListTile.subtitle], and [page] is the name of the screen that will
/// be pushed when the card is tapped (using [NavigatorState.pushNamed]).
class InfoCard extends StatelessWidget {
	/// The icon for this card. 
	final IconData icon;

	/// The text passed to [ListTile.subtitle]. 
	/// 
	/// Every string in the iterable is put on it's own line. 
	final Iterable<String>? children;

	/// The heading of the tile. 
	final String title;

	/// The name of the page to navigate to if pressed.
	final String page;

	/// Creates an info tile. 
	const InfoCard ({
		required this.title,
		required this.icon, 
		required this.page,
		this.children, 
	});

	@override Widget build (BuildContext context) => Card (
		child: ListTile (
			leading: Icon (icon),
			title: Text (title, textScaleFactor: 1.2),
			onTap: () => Navigator.of(context).pushNamed(page),
			subtitle: children == null ? null : Align (
				alignment: const Alignment (-0.75, 0),
				child: Column (
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const SizedBox (height: 5),
						...[
							for (final String text in children!) ...[
								const SizedBox(height: 2.5),
								Text(text, textScaleFactor: 1.25),
								const SizedBox(height: 2.5),
							]
						]
					] 
				)
			)
		)
	);
}