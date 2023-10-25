import "package:flutter/material.dart";

import "package:ramaz/constants.dart";

import "../images/link_icon.dart";
import "../images/loading_image.dart";

/// Brand logos used throughout the app. 
/// 
/// Ram Life does not claim ownership of any brand 
/// (except for the Ramaz logo).  
class Logos {
	/// The Google logo. 
	static const Widget google = CircleAvatar (
		backgroundColor: Colors.transparent,
		backgroundImage: AssetImage(
			"images/logos/google_sign_in.png",
		),
	);

	/// The Google Drive logo. 
	static const Widget drive = LinkIcon (
		path: "images/logos/drive.png",
		url: Urls.googleDrive,
	);

	/// The Microsoft Outlook logo. 
	static const Widget outlook = LinkIcon (
		path: "images/logos/outlook.jpg",
		url: Urls.email,
	);

	/// The Schoology logo. 
	static const Widget schoology = LinkIcon (
		path: "images/logos/schoology.png",
		url: Urls.schoology,
	);

	/// The Ramaz website logo. 
	static const Widget ramazIcon = LinkIcon (
		path: "images/logos/ramaz/teal.jpg",
		url: Urls.ramaz,
	);

	/// The Senior Systems (My Backpack) logo. 
	static const seniorSystems = LinkIcon (
		path: "images/logos/senior_systems.png",
		url: Urls.seniorSystems,
	);
}

/// Logos belonging to ramaz. 
class RamazLogos {
	/// The light blue, square Ramaz logo.
	/// 
	/// https://pbs.twimg.com/profile_images/378800000152983492/5724a8d14e67b53234ed96e3235fe526.jpeg
	static const Widget teal = LoadingImage(
		image: AssetImage("images/logos/ramaz/teal.jpg"),
		aspectRatio: 1,
	);

	/// The Ramaz logo with a Ram head and the words Ramaz underneath. 
	/// 
	/// Like https://www.the-rampage.org/wp-content/uploads/2019/08/IMG_0432.png,
	/// but with the word Ramaz underneath. 
	static const Widget ramSquareWords = LoadingImage(
		image: AssetImage("images/logos/ramaz/ram_square_words.png"),
		aspectRatio: 0.9276218611521418,
	);

	/// A ram head. 
	/// 
	/// https://www.the-rampage.org/wp-content/uploads/2019/08/IMG_0432.png
	static const Widget ramSquare = LoadingImage(
		image: AssetImage("images/logos/ramaz/ram_square.png"),
		aspectRatio: 1.0666666666666667,
	);

	/// The Ramaz Ram with the word Ramaz to its right. 
	/// 
	/// https://www.the-rampage.org/wp-content/uploads/2019/08/IMG_0432.png
	/// with https://upload.wikimedia.org/wikipedia/commons/a/aa/RamazNewLogo_BLUE_RGB_Large72dpi.jpg
	/// next to it. 
	static const Widget ramRectangle = LoadingImage(
		image: AssetImage("images/logos/ramaz/ram_rectangle.png"),
		aspectRatio: 2.8915864378401004,
	);
}
