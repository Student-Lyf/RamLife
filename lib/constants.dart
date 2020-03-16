library constants;

import "package:flutter/material.dart" show Color;

/// A container for Ramaz-specific colors
/// 
/// See https://material.io/resources/color/#!/primary.color=004b8d&secondary.color=f9ca15
/// for visuals.
class RamazColors {
	/// Ramaz's brand blue.
	static const Color blue = Color(0xFF004B8D);

	/// Ramaz's brand gold.
	static const Color gold = Color(0xFFF9CA15);

	/// The material-specific light variant of [blue].
	static const Color blueLight = Color(0xFF4A76BE);

	/// The material-specific dark variant of [blue].
	static const Color blueDark = Color (0xFF00245F);

	/// The material-specific dark variant of [gold].	
	static const Color goldDark = Color (0xFFC19A00);

	/// The material-specific light variant of [gold].	
	static const Color goldLight = Color (0xFFFFFD56);
}

/// Route names for each page in the app.
/// 
/// These would be enums, but Flutter requires Strings. 
class Routes {
	/// The route name for the home page.
	static const String home = "home";

	/// The route name for the schedule page.
	static const String schedule = "schedule";

	/// The route name for the reminders page.
	static const String reminders = "reminders";

	/// The route name for the login page.
	static const String login = "login";

	/// The route name for the feedback page.
	static const String feedback = "feedback";

	/// The route name for the calendar page. 
	static const String calendar = "calendar";

	/// The route name for the specials manager page. 
	static const String specials = "specials";

	/// The route name for the admin home page. 
	static const String admin = "admin";

	/// The route name for the sports games page.
	static const String sports = "sports";
}

/// A collection of URLs used throughout the app
class Urls {
	/// The URL for schoology.
	static const String schoology = "https://app.schoology.com";

	/// The URL for Outlook mail.
	static const String email = "http://mymail.ramaz.org";

	/// The URL for the Ramaz website.
	static const String ramaz = "https://www.ramaz.org";

	/// The URL for Google Drive.
	static const String googleDrive = "http://drive.google.com";

	/// The URL for Outlook mail.
	static const String seniorSystems = "https://my.ramaz.org/SeniorApps/facelets/home/home.xhtml";

	/// The URL for Ramaz livestreaming. 
	static const String sportsLivestream = "https://ramaz.org/streaming";
}

/// Some date constants.
class Times {
	/// The month that school starts (September).
	static const int schoolStart = 9;

	/// The month that school ends (July).
	static const int schoolEnd = 7;

	/// The month that winter Fridays start (November).
	static const int winterFridayMonthStart = 11;

	/// The month that winter Fridays end (March).
	static const int winterFridayMonthEnd = 3;

	/// The date that Winter Fridays start (assume the 1st).
	static const int winterFridayDayStart = 1;

	/// The date that Winter Fridays end (assume the 1st).
	static const int winterFridayDayEnd = 1;
}
