import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// The main app widget. 
class RamazApp extends StatelessWidget {
	/// Whether the user is already signed in. 
	final bool isSignedIn;

	/// Creates the main app widget.
	const RamazApp ({
		this.isSignedIn,
	});

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
		),
		builder: (BuildContext context, ThemeData theme) => MaterialApp (
			home: isSignedIn == null 
				? SplashScreen()
				: isSignedIn ? HomePage() : Login(),
			title: "Ram Life",
			color: RamazColors.blue,
			theme: theme,
			routes: {
				Routes.login: (_) => Login(),
				Routes.home: (_) => HomePage(),
				Routes.schedule: (_) => SchedulePage(),
				Routes.reminders: (_) => RemindersPage(),
				Routes.feedback: (_) => FeedbackPage(),
				Routes.calendar: (_) => CalendarPage(),
				Routes.specials: (_) => SpecialPage(),
				Routes.admin: (_) => AdminHomePage(),
				Routes.sports: (_) => SportsPage(),
			}
		)
	);
}
