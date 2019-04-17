import "package:flutter/material.dart";

class InfoCard extends StatelessWidget {
	final IconData icon;
	final Iterable<String> children;
	final String title;

	const InfoCard ({
		@required this.title,
		@required this.icon, 
		this.children = const [], 
	});

	@override Widget build (BuildContext context) => Card (
		child: ListTile (
			leading: Icon (icon),
			title: Text (title, textScaleFactor: 1.2),
			subtitle: children == null ? null : Align (
				alignment: const Alignment (-0.75, 0),
				child: Column (
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						SizedBox (height: 5)
					] + children.map<Widget> (
						(String text) => Padding (
							padding: const EdgeInsets.symmetric(vertical: 2.5),
							child: Text (text, textScaleFactor: 1.25)
						)
					).toList()
				)
			)
		)
	);
}