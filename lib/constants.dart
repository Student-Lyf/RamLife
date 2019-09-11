library constants;

import "package:flutter/material.dart" show Color;

class RamazColors {
	static const Color BLUE = Color(0xFF004B8D);  // (255, 0, 75, 140);
	static const Color GOLD = Color(0xFFF9CA15);
	static const Color BLUE_LIGHT = Color(0XFF4A76BE);
	static const Color BLUE_DARK = Color (0xFF00245F);
	static const Color GOLD_DARK = Color (0XFFC19A00);
	static const Color GOLD_LIGHT = Color (0XFFFFFD56);
}


class Routes {
	static const String HOME = "home";
	static const String SCHEDULE = "schedule";
	static const String NOTES = "notes";
	static const String LOST_AND_FOUND = "lost-and-found";
	static const String SPORTS = "sports";
	static const String ADMIN_LOGIN = "admin-login";
	static const String LOGIN = "login";
	static const String FEEDBACK = "feedback";
	static const String PUBLICATIONS = "publications";
}

class Urls {
	static const String SCHOOLOGY = "https://app.schoology.com";
	static const String EMAIL = "http://mymail.ramaz.org";
	static const String RAMAZ = "https://www.ramaz.org";
	static const String GOOGLE_DRIVE = "http://drive.google.com";
	static const String SENIOR_SYSTEMS = "https://my.ramaz.org/SeniorApps/facelets/home/home.xhtml";  // TODO 
}
