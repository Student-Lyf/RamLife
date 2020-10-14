import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter/material.dart" show required, immutable;

import "package:ramaz/constants.dart";

import "service.dart";

/// Describes how a reminders notification should look. 
NotificationDetails reminderDetails = const NotificationDetails(
	android: AndroidNotificationDetails(
		"reminders",
		"Reminders",
		"When reminders are due.",
		importance: Importance.high,
		priority: Priority.high,
		color: RamazColors.blue,
		groupKey: "reminders",
		playSound: true,
		enableVibration: true,
		setAsGroupSummary: false,
		channelShowBadge: true,
		icon: null,
		styleInformation: null,
		enableLights: true,
	),
	iOS: IOSNotificationDetails(
		presentBadge: true,
		presentSound: true
	)
);

/// A platform-agnostic notification.
/// 
/// Helps creating [NotificationDetails].
@immutable 
class Notification {
	/// The ID of this notification.
	/// 
	/// The ID is used for canceling the notifications. 
	int get id => 0;

	/// The title of this notification.
	final String title;

	/// The body of this notification.
	final String message;

	/// The platform-agnostic [NotificationDetails] for this class.  
	final NotificationDetails details;

	/// Returns a new [Notification]. 
	const Notification({
		@required this.title,
		@required this.message,
		@required this.details,
	});

	/// The optimal configuration for a reminder notification.
	Notification.reminder({
		@required this.title,
		@required this.message,
	}) : details = reminderDetails;
}

/// An abstract wrapper around the notifications plugin. 
/// 
/// There are two types of notifications: local notifications, and push
/// notifications. Local notifications are sent by the app itself, and 
/// push notifications are sent by the server. These are local notifications. 
/// 
/// Local notifications can be customized to appear differently depending on
/// the type of notification and platform. They can also be scheduled to appear
/// at certain times. This is based on [FlutterLocalNotificationsPlugin].
/// 
/// Currently, Web is not supported. 
class Notifications extends Service {
	final _plugin = FlutterLocalNotificationsPlugin();

	@override
	Future<void> init() => _plugin.initialize(
		const InitializationSettings(
			android: AndroidInitializationSettings(
				"@mipmap/bright_yellow"  // default icon of app
			),
			iOS: IOSInitializationSettings(),  // defaults are good
		)
	);

	@override
	Future<void> signIn() async {}

	/// Sends a notification immediately. 
	void sendNotification(Notification notification) => _plugin.show(
		notification.id, 
		notification.title, 
		notification.message, 
		notification.details,
	);

	/// Schedules a notification for [date]. 
	/// 
	/// If [date] is in the past, the notification will go off immediately.
	void scheduleNotification({
		@required Notification notification,
		@required DateTime date, 
	}) => _plugin.zonedSchedule(
		notification.id,
		notification.title,
		notification.message,
		date,
		notification.details,
		androidAllowWhileIdle: true,
		uiLocalNotificationDateInterpretation: 
			UILocalNotificationDateInterpretation.wallClockTime,
	);

	/// Cancels all scheduled notifications, as well as 
	/// dismissing all present notifications. 
	void cancelAll() => _plugin.cancelAll();
}
