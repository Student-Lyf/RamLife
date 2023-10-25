import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:timezone/data/latest.dart" as tz;
import "package:timezone/timezone.dart" as tz;

// ignore: directives_ordering
import "package:ramaz/constants.dart";

import "../notifications.dart";

/// Creates a reminders notification using [MobileNotification.reminder].
Notification getReminderNotification({
	required String title, 
	required String message,
}) => MobileNotification.reminder(title: title, message: message);

/// The mobile implementation of the [Notifications] service. 
Notifications get notifications => MobileNotifications();

/// The mobile version of a notification. 
/// 
/// A [MobileNotification] has a [NotificationDetails] to control how the 
/// notification appears on the device. 
class MobileNotification extends Notification {
	/// Describes how a reminders notification should look. 
	static NotificationDetails reminderDetails = const NotificationDetails(
		android: AndroidNotificationDetails(
			"reminders",
			"Reminders",
			channelDescription: "When reminders are due.",
			importance: Importance.high,
			priority: Priority.high,
			color: RamazColors.blue,
			groupKey: "reminders",
			enableLights: true,
		),
		iOS: DarwinNotificationDetails(
			presentBadge: true,
			presentSound: true,
		),
	);

	/// The platform-agnostic [NotificationDetails] for this class.  
	final NotificationDetails details;

	/// Creates a new [Notification]. 
	const MobileNotification({
		required super.title,
		required super.message,
		required this.details,
	});

	/// The optimal configuration for a reminder notification.
	MobileNotification.reminder({
		required super.title,
		required super.message,
	}) : 
		details = reminderDetails;
}

/// The mobile implementation of the notifications service. 
class MobileNotifications extends Notifications {
	/// The plugin on mobile. 
	final plugin = FlutterLocalNotificationsPlugin();

	@override
	Future<void> init() async {
		await plugin.initialize(
			const InitializationSettings(
				android: AndroidInitializationSettings(
					"@mipmap/bright_yellow",  // default icon of app
				),
				iOS: DarwinInitializationSettings(),  // defaults are good
			),
		);
		tz.initializeTimeZones();
	}

	@override
	Future<void> signIn() async {}

	@override
	void sendNotification(MobileNotification notification) => plugin.show(
		Notification.id, 
		notification.title, 
		notification.message, 
		notification.details,
	);

	@override
	void scheduleNotification({
		required MobileNotification notification,
		required DateTime date, 
	}) => plugin.zonedSchedule(
		Notification.id,
		notification.title,
		notification.message,
		tz.TZDateTime.from(date, tz.local),
		notification.details,
		androidAllowWhileIdle: true,
		uiLocalNotificationDateInterpretation: 
			UILocalNotificationDateInterpretation.wallClockTime,
	);

	@override
	void cancelAll() => plugin.cancelAll();

	@override
	Future<List<String>> get pendingNotifications async => [
		for (
			final PendingNotificationRequest request in 
			await plugin.pendingNotificationRequests()
		) 
			request.title!,
	];
}
