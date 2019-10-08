import "package:flutter/material.dart";

import "package:ramaz/constants.dart";

import "../images/link_icon.dart";
import "../images/loading_image.dart";

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
		backgroundColor: Colors.white,
		child: Image.asset ("images/icons/tennis.png"),
	);

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
		url: Urls.googleDrive
	);

	static const Widget outlook = LinkIcon (
		path: "images/logos/outlook.jpg",
		url: Urls.email
	);

	static const Widget schoology = LinkIcon (
		path: "images/logos/schoology.png",
		url: Urls.schoology
	);

	static const Widget ramazIcon = LinkIcon (
		path: "images/logos/ramaz/teal.jpg",
		url: Urls.ramaz
	);

	static const seniorSystems = LinkIcon (
		path: "images/logos/senior_systems.png",
		url: Urls.seniorSystems
	);
}

class RamazLogos {
	static const Widget teal = LoadingImage (
		"images/logos/ramaz/teal.jpg",
		aspectRatio: 1
	);

	static const Widget ramSquareWords = LoadingImage (
		"images/logos/ramaz/ram_square_words.png",
		aspectRatio: 0.9276218611521418
	);

	static const Widget ramSquare = LoadingImage(
		"images/logos/ramaz/ram_square.png",
		aspectRatio: 1.0666666666666667
	);

	static const Widget ramRectangle = LoadingImage (
		"images/logos/ramaz/ram_rectangle.png",
		aspectRatio: 2.8915864378401004
	);
}
