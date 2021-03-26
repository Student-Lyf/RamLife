import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";
import "package:ramaz/services.dart";

/// The main app widget. 
class RamLife extends StatefulWidget {
	/// Creates the main app widget.
	const RamLife();

	@override
	RamLifeState createState() => RamLifeState();
}

/// The state for the app.
class RamLifeState extends State<RamLife> {
	@override 
	Widget build (BuildContext context) => ThemeChanger(
		defaultBrightness: Brightness.light,
		light: ThemeData (
			brightness: Brightness.light,
			primarySwatch: Colors.blue,
			primaryColor: RamazColors.blue,
			primaryColorBrightness: Brightness.dark,
			primaryColorLight: RamazColors.blueLight,
			primaryColorDark: RamazColors.blueDark,
			accentColor: RamazColors.gold,
			accentColorBrightness: Brightness.light,
			textSelectionTheme: const TextSelectionThemeData(
				cursorColor: RamazColors.blueLight,
				selectionHandleColor: RamazColors.blueLight,
			),
			buttonColor: RamazColors.gold,
			buttonTheme: const ButtonThemeData (
				buttonColor: RamazColors.gold,
				textTheme: ButtonTextTheme.normal,
			),
			elevatedButtonTheme: ElevatedButtonThemeData(
				style: ButtonStyle(
					backgroundColor: MaterialStateProperty.all(RamazColors.gold)
				)
			)
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
			textSelectionTheme: const TextSelectionThemeData(
				cursorColor: RamazColors.blueLight,
				selectionHandleColor: RamazColors.blueLight,
			),
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

	/// Enforces the user be signed in.
	WidgetBuilder enforceLogin(WidgetBuilder builder) => 
		(_) => RouteInitializer(
			isAllowed: () => Auth.isSignedIn,
			builder: builder,
		);
}