import "package:flutter/material.dart";
import "package:ramaz/widgets/loading_image.dart";

const double radius = 40;

class SportsIcons {
	static const Widget baseball = CircleAvatar (
		child: LoadingImage (
			"images/icons/baseball.png",
			width: radius,
			height: radius
		)
	);

	static const Widget basketball = CircleAvatar (
		child: LoadingImage (
			"images/icons/basketball.png",
			width: radius,
			height: radius
		)
	);

	static const Widget hockey = CircleAvatar (
		child: LoadingImage (
			"images/icons/hockey.png",
			width: radius,
			height: radius
		)
	);

	static const Widget soccer = CircleAvatar (
		child: LoadingImage (
			"images/icons/soccer.png",
			width: radius,
			height: radius
		)
	);

	static const Widget tennis = CircleAvatar (
		child: LoadingImage (
			"images/icons/tennis.png",
			width: radius,
			height: radius
		)
	);

	static const Widget volleyball = CircleAvatar (
		child: LoadingImage (
			"images/icons/volleyball.png",
			width: radius,
			height: radius
		)
	);
}

class Logos {
	static const Widget drive = CircleAvatar (
		child: LoadingImage (
			"images/logos/drive.png",
			width: radius,
			height: radius
		)
	);

	static const Widget google = CircleAvatar (
		child: LoadingImage (
			"images/logos/google.png",
			width: radius,
			height: radius
		)
	);

	static const Widget outlook = CircleAvatar (
		child: LoadingImage (
			"images/logos/outlook.png",
			width: radius,
			height: radius
		)
	);

	static const Widget schoology = CircleAvatar (
		child: LoadingImage (
			"images/logos/schoology.png",
			width: radius,
			height: radius
		)
	);
}

class RamazLogos {
	static const Widget teal = CircleAvatar (
		child: LoadingImage (
			"images/logos/ramaz/teal.png",
			width: radius,
			height: radius
		)
	);

	static const Widget ram_square_words = CircleAvatar (
		child: LoadingImage (
			"images/logos/ramaz/ram_square_words.png",
			width: radius,
			height: radius
		)
	);

	static const Widget ram_square = CircleAvatar (
		child: LoadingImage (
			"images/logos/ramaz/ram_square.png",
			width: radius,
			height: radius
		)
	);

	static const Widget ram_rectangle = CircleAvatar (
		child: LoadingImage (
			"images/logos/ramaz/ram_rectangle.png",
			width: radius,
			height: radius
		)
	);
}
