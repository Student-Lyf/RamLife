import "package:flutter/material.dart";

class InfoCard extends StatelessWidget {
	final IconData icon;
	final Iterable<String> children;
	final String title, page;

	const InfoCard ({
		@required this.title,
		@required this.icon, 
		@required this.children, 
		this.page,
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
							for (final String text in children) ...[
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