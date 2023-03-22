import "package:flutter/material.dart";

import "package:ramaz/constants.dart";
import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/services.dart";
import "package:ramaz/widgets.dart";

/// The main app widget. 
class RamLife extends StatelessWidget {
	/// Determines whether the user is an admin with the given scope.  
	static bool hasAdminScope(AdminScope scope) => Auth.isSignedIn
		&& Models.instance.user.isAdmin
		&& Models.instance.user.adminScopes!.contains(scope);

	/// The routes for this app.
	static final Map<String, WidgetBuilder> routes = {
		Routes.login: (_) => RouteInitializer(
			onError: null,
			isAllowed: () => true,
			child: const Login(),
		),
		Routes.home: (_) => const RouteInitializer(
			child: HomePage(pageIndex: 0),
		),
		Routes.schedule: (_) => const RouteInitializer(
			child: HomePage(pageIndex: 1),
		),
		Routes.reminders: (_) => const RouteInitializer(
			child: HomePage(pageIndex: 2),
		),
		Routes.feedback: (_) => const RouteInitializer(
			child: FeedbackPage(),
		),
		Routes.calendar: (_) => RouteInitializer(
			isAllowed: () => hasAdminScope(AdminScope.calendar),
			child: const AdminCalendarPage(),
		),
		Routes.schedules: (_) => RouteInitializer(
			isAllowed: () => hasAdminScope(AdminScope.calendar),
			child: const AdminSchedulesPage(),
		),
		Routes.sports: (_) => const RouteInitializer(
			child: HomePage(pageIndex: 3),
		),
		Routes.credits: (_) => const RouteInitializer(
			child: CreditsPage(),
		),
	};

	/// Provides a const constructor.
	const RamLife();

	@override 
	Widget build (BuildContext context) => ThemeChanger(
		defaultBrightness: Brightness.light,
		light: ThemeData (
			colorScheme: const ColorScheme.light(
				primary: RamazColors.blue,
				// primaryVariant: RamazColors.blueDark,
				secondary: RamazColors.gold,
				// secondaryVariant: RamazColors.goldDark,
				brightness: Brightness.light
			),
			textSelectionTheme: const TextSelectionThemeData(
				cursorColor: RamazColors.blueLight,
				selectionHandleColor: RamazColors.blueLight,
			),
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
			colorScheme: const ColorScheme.dark(
				primary: RamazColors.blue,
				// primaryVariant: RamazColors.blueDark,
				secondary: RamazColors.gold,
				// secondaryVariant: RamazColors.goldDark,
				brightness: Brightness.dark
			),
			iconTheme: const IconThemeData (color: RamazColors.goldDark),
			primaryIconTheme: const IconThemeData (color: RamazColors.goldDark),
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
					return routes [routeName]! (context);
				},
			)
		)
	);
}
