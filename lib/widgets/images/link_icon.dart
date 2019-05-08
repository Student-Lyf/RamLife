import "package:flutter/material.dart";

import "package:url_launcher/url_launcher.dart" show launch;

class LinkIcon extends StatelessWidget {
	final String path, url;
	const LinkIcon ({@required this.path, @required this.url});

	@override Widget build(BuildContext context) => IconButton (
		icon: CircleAvatar(
			backgroundImage: AssetImage(path),
			// radius: 50
		),
		iconSize: 50,
		onPressed: () => launch (url)
	);
}