import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// The main app widget. 
class RamLife extends StatelessWidget {
	/// The routes for this app.
	static final Map<String, WidgetBuilder> routes = {
		Routes.login: (_) => Login(),
		Routes.home: (_) => const HomePage(),
		Routes.schedule: (_) => const HomePage(pageIndex: 1),
		Routes.reminders: (_) => const HomePage(pageIndex: 2),
		Routes.feedback: (_) => FeedbackPage(),
		Routes.calendar: (_) => CalendarPage(),
		Routes.specials: (_) => SpecialPage(),
		Routes.admin: (_) => AdminHomePage(),
		Routes.sports: (_) => SportsPage(),
	};

	/// Provides a const constructor.
	const RamLife();

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
			onGenerateRoute: (RouteSettings settings) => PageRouteBuilder(
        settings: settings, 
        transitionDuration: Duration.zero,
        pageBuilder: (BuildContext context, __, ___) {
        	final String routeName = 
        		(settings.name == null || !routes.containsKey(settings.name))
	        		? Routes.home : settings.name!;
	        return settings.name == Routes.login 
	        	? RouteInitializer(
	        		// If this page is Routes.login, don't set an error handler.
	        		onError: null ,
	        		isAllowed: () => true,
	        		child: routes [routeName]! (context),
        		)
        		: RouteInitializer(
        			child: routes [routeName]! (context),
      			);
        },
      )
		)
	);
}
