import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:meta/meta.dart";
import "package:timezone/timezone.dart";
import "package:timezone/data/latest.dart";
import "package:flutter_native_timezone/flutter_native_timezone.dart";

import "package:ramaz/constants.dart";

import "../notifications.dart";

/// Creates a reminders notification using [MobileNotification.reminder].
Notification getReminderNotification({
	@required String title, 
	@required String message,
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

	/// The platform-agnostic [NotificationDetails] for this class.  
	final NotificationDetails details;

	/// Creates a new [Notification]. 
	const MobileNotification({
		@required String title,
		@required String message,
		@required this.details,
	}) : super(title: title, message: message);

	/// The optimal configuration for a reminder notification.
	MobileNotification.reminder({
		@required String title,
		@required String message,
	}) : 
		details = reminderDetails, 
		super(title: title, message: message);
}

/// The mobile implementation of the notifications service. 
class MobileNotifications extends Notifications {
	/// The plugin on mobile. 
	final plugin = FlutterLocalNotificationsPlugin();

	/// The location this device is in. 
	String timezoneName;

	/// The location (and timezones) this device is in.
	Location location;

	@override
	Future<void> init() async {
		await plugin.initialize(
			const InitializationSettings(
				android: AndroidInitializationSettings(
					"@mipmap/bright_yellow"  // default icon of app
				),
				iOS: IOSInitializationSettings(),  // defaults are good
			)
		);
		initializeTimeZones();
		timezoneName = await FlutterNativeTimezone.getLocalTimezone();
		location = getLocation(timezoneName);
	}

	@override
	Future<void> signIn() async {}

	@override
	void sendNotification(
		covariant MobileNotification notification
	) => plugin.show(
		notification.id, 
		notification.title, 
		notification.message, 
		notification.details,
	);

	@override
	void scheduleNotification({
		@required covariant MobileNotification notification,
		@required DateTime date, 
	}) => plugin.zonedSchedule(
		notification.id,
		notification.title,
		notification.message,
		TZDateTime.from(date, location),
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
			request.title
	];
}
