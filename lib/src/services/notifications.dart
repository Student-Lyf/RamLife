import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter/material.dart" show Color, required, immutable;

import "package:ramaz/constants.dart";

/// The style of the notification.
/// 
/// Only applies to Android.
enum AndroidNotificationType {
	/// A message notification from another person. 
	/// 
	/// This can be used for lost and found notifications.
	message, 

	/// A notification that contains an image. 
	/// 
	/// This can be used for the first post of lost and found notifications
	/// that contain an image of the lost object.
	image, 

	/// A default notification with just text. 
	normal,
}

/// Maps the abstract [AndroidNotificationType] to [AndroidNotificationStyle]s.
/// 
/// This is done so other libraries that import this module do not need to 
/// import `flutter_local_notifications`. 
const Map<
	AndroidNotificationType, 
	AndroidNotificationStyle
> androidNotificationTypes = {
	AndroidNotificationType.message: AndroidNotificationStyle.Messaging,
	AndroidNotificationType.image: AndroidNotificationStyle.BigPicture,
	AndroidNotificationType.normal: AndroidNotificationStyle.Default,
};

/// A notification configuration for Android. 
/// 
/// This should be used instead of [AndroidNotificationDetails] so that other 
/// other libraries can import this module without importing the plugin. 
@immutable
class AndroidNotification {
	/// The importance of this notification.
	/// 
	/// An importance level for Android 8+
	final Importance importance;

	/// The priority of this notification.
	/// 
	/// An importance level for Android 7.1 and lower. 
	final Priority priority;

	/// The type of this notification.
	final AndroidNotificationType style;

	/// The style of this notification.
	/// 
	/// This can be used to customize notfications about messages 
	/// and notifications that contain images. 
	final StyleInformation styleInfo;

	/// The color of this notfication.
	/// 
	/// Should relate to the app's branding colors. 
	final Color color;

	/// The ID of this notification's channel.
	final String channelId;

	/// The name of this notification's channel.
	final String channelName;

	/// The description of this notification's channel.
	final String channelDescription;

	/// The icon for this notification.
	/// 
	/// Defaults to the default app icon, but can be customized. 
	final String icon;

	/// The group ID for this notification. 
	/// 
	/// All notifications with the same group ID are bundled together.
	final String groupId;

	/// Whether this notification should play sound. 
	final bool playSound;

	/// Whether this notification should vibrate the device. 
	final bool shouldVibrate;
	
	/// Whether this is the header of a group. 
	final bool isGroupSummary;
	
	/// Whether this notification's channel should cause the home screen
	/// to show a badge on the app's icon.
	final bool showChannelBadge;

	/// Whether this notification should cause the device's LED to blink.
	final bool showLight;

	/// A const constructor for this class.
	const AndroidNotification({
		@required this.importance,
		@required this.priority,
		@required this.style,
		@required this.color,
		@required this.channelId,
		@required this.channelName,
		@required this.channelDescription,
		@required this.groupId,
		@required this.playSound,
		@required this.shouldVibrate,
		@required this.isGroupSummary,
		@required this.showChannelBadge,
		@required this.showLight,
		this.icon,
		this.styleInfo,
	});

	/// An optimal Android notification configuration for reminders. 
	/// 
	/// If [root] is true, the notification is considered the group 
	/// "summary", which is like a header for notifications. 
	const AndroidNotification.reminder({bool root = false}) :
		importance = Importance.High,
		priority = Priority.High,
		style = AndroidNotificationType.normal,
		color = RamazColors.blue,
		channelId = "reminders",
		channelName = "Reminders",
		channelDescription = "When reminders are due.",
		groupId = "reminders",
		playSound = true,
		shouldVibrate = true,
		isGroupSummary = root,
		showChannelBadge = true,
		icon = null,
		styleInfo = null,
		showLight = true;

	/// Exposes the AndroidNotificationDetails for this notification.
	AndroidNotificationDetails get details => AndroidNotificationDetails(
		channelId,
		channelName,
		channelDescription,
		icon: icon,
		importance: importance,
		priority: priority,
		style: androidNotificationTypes [style],
		styleInformation: styleInfo, 
		playSound: playSound,
		enableVibration: shouldVibrate,
		groupKey: groupId,
		setAsGroupSummary: isGroupSummary,
		groupAlertBehavior: GroupAlertBehavior.All,
		autoCancel: true,
		ongoing: false,
		color: color,
		onlyAlertOnce: true,
		channelShowBadge: showChannelBadge,
		enableLights: showLight,
		ledColor: color,
		ledOnMs: 1000,
		ledOffMs: 5000,
	);
}

/// A notification configuration for iOS. 
/// 
/// This should be used instead of [IOSNotificationDetails] so that other 
/// other libraries can import this module without importing the plugin. 
@immutable
class IOSNotification {
	/// An optimal [IOSNotification] for reminders. 
	static const IOSNotification reminder = IOSNotification(
		showBadge: true,
		playSound: true
	);

	/// Whether this notification should cause the device's homescreen
	/// to show a badge on this notification's icon. 
	final bool showBadge;
	
	/// Whether this notification should cause the device to play a sound. 
	final bool playSound;

	/// A const constructor for this class. 
	const IOSNotification({
		@required this.showBadge,
		@required this.playSound
	});

	/// The [IOSNotificationDetails] for this notification.
	IOSNotificationDetails get details => IOSNotificationDetails(
		presentAlert: true,
		presentSound: playSound,
		presentBadge: showBadge,
	);
}

/// A platform-agnostic notification.
/// 
/// An [AndroidNotification] and an [IOSNotification] needs to be provided.
@immutable 
class Notification {
	/// The ID of this notification.
	/// 
	/// The ID is used for cancelling the notifications. 
	final int id = 0;

	/// The title of this notification.
	final String title;

	/// The body of this notification.
	final String message;

	/// The platform-agnostic [NotificationDetails] for this class.  
	final NotificationDetails details;

	/// Returns a new [Notification]. 
	/// 
	/// [android] and [ios] are used to make [details].
	Notification({
		@required this.title,
		@required this.message,
		@required AndroidNotification android,
		@required IOSNotification ios,
	}) : details = NotificationDetails(
			android.details, ios.details,
		);

	/// The optimal configuration for a reminder notification.
	Notification.reminder({
		@required this.title,
		@required this.message,
		bool root = false
	}) : 
		details = NotificationDetails(
			AndroidNotification.reminder(root: root).details, 
			IOSNotification.reminder.details,	
		);
}

// ignore: avoid_classes_with_only_static_members
/// An abstract wrapper around the notifications plugin. 
/// 
/// This class uses static methods to send and schedule
/// notifications.
class Notifications {
	static final _plugin = FlutterLocalNotificationsPlugin()
		..initialize(
			const InitializationSettings(
				AndroidInitializationSettings(
					"@mipmap/bright_yellow"  // default icon of app
				),
				IOSInitializationSettings(),  // defaults are good
			)
		);

	/// Sends a notification immediately. 
	static void sendNotification(Notification notification) => _plugin.show(
		notification.id, 
		notification.title, 
		notification.message, 
		notification.details,
	);

	/// Schedules a notification for [date]. 
	/// 
	/// If [date] is in the past, the notification will go off immediately.
	static void scheduleNotification({
		@required Notification notification,
		@required DateTime date, 
	}) => _plugin.schedule(
		notification.id,
		notification.title,
		notification.message,
		date,
		notification.details,
		androidAllowWhileIdle: true,
	);

	/// Cancels all scheduled notifications, as well as 
	/// dismissing all present notifications. 
	static void cancelAll() => _plugin.cancelAll();
}
