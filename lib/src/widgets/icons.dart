import "package:flutter/material.dart";

import "images/loading_image.dart";
import "images/link_icon.dart";

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
		url: Urls.google_drive
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

	static const senior_systems = LinkIcon (
		path: "images/logos/senior_systems.png",
		url: Urls.seniorSystems
	);
}

class RamazLogos {
	static const Widget teal = LoadingImage (
		"images/logos/ramaz/teal.jpg",
		aspectRatio: 1
	);

	static const Widget ram_square_words = LoadingImage (
		"images/logos/ramaz/ram_square_words.png",
		aspectRatio: 0.9276218611521418
	);

	static const Widget ram_square = LoadingImage(
		"images/logos/ramaz/ram_square.png",
		aspectRatio: 1.0666666666666667
	);

	static const Widget ram_rectangle = LoadingImage (
		"images/logos/ramaz/ram_rectangle.png",
		aspectRatio: 2.8915864378401004
	);
}
