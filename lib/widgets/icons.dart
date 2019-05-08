import "package:flutter/material.dart";

import "package:ramaz/widgets/images/loading_image.dart";
import "package:ramaz/widgets/images/link_icon.dart";

import "package:ramaz/constants.dart";

const double radius = 40;

class SportsIcons {
	static const Widget baseball = CircleAvatar (
		backgroundImage: AssetImage ("images/icons/baseball.png"),
		backgroundColor: Colors.white
	);

	static const Widget basketball = CircleAvatar (
		backgroundImage: AssetImage ("images/icons/basketball.png"),
		backgroundColor: Colors.white
	);

	static const Widget hockey = CircleAvatar (
		backgroundImage: AssetImage ("images/icons/hockey.png"),
		backgroundColor: Colors.white
	);

	static const Widget soccer = CircleAvatar (
		backgroundImage: AssetImage ("images/icons/soccer.png"),
		backgroundColor: Colors.white
	);

	static final Widget tennis = CircleAvatar (
		child: Image.asset ("images/icons/tennis.png"),
		backgroundColor: Colors.white
	);

	// static final Widget tennis = Image.asset (
	// 	"images/icons/tennis.png",
	// 	height: 30,
	// 	width: 30
	// );

	static const Widget volleyball = CircleAvatar (
		backgroundImage: AssetImage ("images/icons/volleyball.png"),
		backgroundColor: Colors.white
	);
}

class Logos {
	static const Widget google = CircleAvatar (
		backgroundImage: AssetImage ("images/logos/google.png"),
		radius: 18,
	);

	static const Widget drive = LinkIcon (
		path: "images/logos/drive.png",
		url: GOOGLE_DRIVE
	);

	static const Widget outlook = LinkIcon (
		path: "images/logos/outlook.jpg",
		url: EMAIL
	);

	static const Widget schoology = LinkIcon (
		path: "images/logos/schoology.png",
		url: SCHOOLOGY
	);

	static const Widget ramazIcon = LinkIcon (
		path: "images/logos/ramaz/teal.jpg",
		url: RAMAZ
	);
}

class RamazLogos {
	static const Widget teal = LoadingImage (
		"images/logos/ramaz/teal.jpg",
		width: 320,
		height: 320
	);

	static const Widget ram_square_words = CircleAvatar (
		backgroundImage: AssetImage ("images/logos/ramaz/ram_square_words.png")
	);

	static const Widget ram_square = LoadingImage(
		"images/logos/ramaz/ram_square.png",
		width: 272,
		height: 137
	);

	static const Widget ram_rectangle = LoadingImage (
		"images/logos/ramaz/ram_rectangle.jpg",
		width: 360,
		height: 124.5
	);
}
