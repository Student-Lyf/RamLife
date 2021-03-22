import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";
import "package:ramaz/services.dart";

/// The main app widget. 
class RamLife extends StatefulWidget {
	/// Whether the user is already signed in. 
	final bool isSignedIn;

	/// Creates the main app widget.
	const RamLife ({this.isSignedIn});

	@override
	RamLifeState createState() => RamLifeState();
}

class RamLifeState extends State<RamLife> {
	@override 
	Widget build (BuildContext context) => ThemeChanger(
		defaultBrightness: null,
		light: ThemeData (
			brightness: Brightness.light,
			primarySwatch: Colors.blue,
			primaryColor: RamazColors.blue,
			primaryColorBrightness: Brightness.dark,
			primaryColorLight: RamazColors.blueLight,
			primaryColorDark: RamazColors.blueDark,
			accentColor: RamazColors.gold,
			accentColorBrightness: Brightness.light,
			cursorColor: RamazColors.blueLight,
			textSelectionHandleColor: RamazColors.blueLight,
			buttonColor: RamazColors.gold,
			buttonTheme: const ButtonThemeData (
				buttonColor: RamazColors.gold,
				textTheme: ButtonTextTheme.normal,
			),
		),
		dark: ThemeData(
			brightness: Brightness.dark,
			scaffoldBackgroundColor: Colors.grey[850],
			primarySwatch: Colors.blue,
			primaryColorBrightness: Brightness.dark,
			primaryColorLight: RamazColors.blueLight,
			primaryColorDark: RamazColors.blueDark,
			accentColor: RamazColors.goldDark,
			accentColorBrightness: Brightness.light,
			iconTheme: const IconThemeData (color: RamazColors.goldDark),
			primaryIconTheme: const IconThemeData (color: RamazColors.goldDark),
			accentIconTheme: const IconThemeData (color: RamazColors.goldDark),
			floatingActionButtonTheme: const FloatingActionButtonThemeData(
				backgroundColor: RamazColors.goldDark,
				foregroundColor: RamazColors.blue
			),
			cursorColor: RamazColors.blueLight,
			textSelectionHandleColor: RamazColors.blueLight,
			cardTheme: CardTheme (
				color: Colors.grey[820]
			),
			toggleableActiveColor: RamazColors.blueLight,
			buttonColor: RamazColors.blueDark,
			buttonTheme: const ButtonThemeData (
				buttonColor: RamazColors.blueDark, 
				textTheme: ButtonTextTheme.accent,
			),
			elevatedButtonTheme: ElevatedButtonThemeData(
				style: ButtonStyle(
					backgroundColor: MaterialStateProperty.all(RamazColors.blueDark)
				)
			),
		),
		builder: (BuildContext context, ThemeData theme) => MaterialApp (
			initialRoute: Routes.home,
			title: "Ram Life",
			color: RamazColors.blue,
			theme: theme,
			routes: {
				Routes.splash: (_) => RouteInitializer(
					isAllowed: () => Auth.isSignedIn,
					builder: (_) => HomePage(),
				),
				Routes.login: (_) => const Login(),
				Routes.home: enforceLogin((_) => HomePage()),
				Routes.schedule: enforceLogin((_) => SchedulePage()),
				Routes.reminders: enforceLogin((_) => RemindersPage()),
				Routes.feedback: enforceLogin((_) => FeedbackPage()),
				Routes.calendar: enforceLogin((_) => CalendarPage()),
				Routes.specials: enforceLogin((_) => SpecialPage()),
				Routes.admin: enforceLogin((_) => AdminHomePage()),
				Routes.sports: enforceLogin((_) => SportsPage()),
			}
		)
	);

	WidgetBuilder enforceLogin(WidgetBuilder builder) => 
		(_) => RouteInitializer(
			isAllowed: () => Auth.isSignedIn,
			builder: builder,
		);

	// WidgetBuilder enforceLogin(WidgetBuilder builder) => 
	// 	(_) {
	// 		if (widget.isSignedIn == null) {
	// 			return SplashScreen();
	// 		} else if (!Services.instance.database.isSignedIn) {
	// 			return Login(builder);
	// 		} else {
	// 			return builder(_);
	// 		}
	// 	};
}



// logic
// initialRoute => route with/out login
// routes: map with custom RouteInitializer
// routeInitializer: 
//  - Route onSuccess
// 	- Route onDeny
// 	- Route onError
// onGenerateRoute: for complex URL logic (not needed yet)


/// Some routeInitializers: 
/// - home: RouteInitializer(
/// 	- isAllowed: isSignedIn
/// 	- onSuccess: Routes.home
/// 	- onDeny: Routes.login
/// 	- onError: reset(); Routes.login
/// )