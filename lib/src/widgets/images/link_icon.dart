import "package:flutter/material.dart";

import "package:url_launcher/url_launcher.dart" show launch;

/// An icon that opens a link when tapped. 
class LinkIcon extends StatelessWidget {
	/// The image to show as the icon. 
	final String path;

	/// The url to open when tapped. 
	final String url;

	/// Creates an icon that opens a webpage. 
	const LinkIcon ({@required this.path, @required this.url});

	@override Widget build(BuildContext context) => IconButton (
		iconSize: 45,
		onPressed: () => launch (url),
		icon: CircleAvatar(backgroundImage: AssetImage(path)),
	);
}