import "package:flutter/material.dart";

import "package:url_launcher/url_launcher.dart";

/// An icon that opens a link when tapped. 
class LinkIcon extends StatelessWidget {
	/// The image to show as the icon. 
	final String path;

	/// The URL to open when tapped. 
	final String url;

	/// Creates an icon that opens a web page. 
	const LinkIcon ({required this.path, required this.url});

	@override Widget build(BuildContext context) => IconButton (
		iconSize: 45,
		onPressed: () => launchUrl(Uri.parse(url)),
		icon: CircleAvatar(backgroundImage: AssetImage(path)),
	);
}
