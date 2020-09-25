library constants;

import "package:flutter/material.dart" show Color, TimeOfDay;

import "package:ramaz/data.dart";

/// A container for Ramaz-specific colors
/// 
/// [blue] and [gold] were taken from seniorelectives.ramaz.org
/// 
/// The other variants were taken from: 
/// https://material.io/resources/color/#!/?view.left=0&view.right=0&primary.color=074d92&secondary.color=fcc30c
class RamazColors {
	/// Ramaz's brand blue.
	static const Color blue = Color(0xff074d92);

	/// Ramaz's brand gold.
	static const Color gold = Color(0xfffcc30c);

	/// The material-specific light variant of [blue].
	static const Color blueLight = Color(0xff4e78c3);

	/// The material-specific dark variant of [blue].
	static const Color blueDark = Color (0xff002664);

	/// The material-specific dark variant of [gold].	
	static const Color goldDark = Color (0xffc49300);

	/// The material-specific light variant of [gold].	
	static const Color goldLight = Color (0xfffff552);
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
	static const String sportsLivestream = "https://www.ramaz.org/page.cfm?p=10769";
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

/// Has a method for checking if a [DateTime] is the same day as another.
extension DayComparison on DateTime {
	/// Returns true if [other] is the same days as this date.
	bool isSameDay(DateTime other) => other.year == year && 
		other.month == month && 
		other.day == day;
}

/// Extension class for converting [TimeOfDay] to a [Time].
extension TimeConverter on TimeOfDay {
	/// Converts this object to a [Time].
	Time get asTime => Time(hour, minute);
}

/// Extension class for converting [Time] to a [TimeOfDay]. 
/// 
/// This cannot be defined in the `data` library, since it would establish 
/// a dependency on the `material` library.
extension TimeOfDayConverter on Time {
	/// Converts this object to a [TimeOfDay].
	TimeOfDay get asTimeOfDay => TimeOfDay(hour: hour, minute: minutes);
}