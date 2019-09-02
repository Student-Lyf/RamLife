import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter/material.dart" show Color, required, immutable;

import "package:ramaz/constants.dart";

enum AndroidNotificationType {
	message, image, normal,
}

const Map<AndroidNotificationType, AndroidNotificationStyle> androidNotificationTypes = {
	AndroidNotificationType.message: AndroidNotificationStyle.Messaging,
	AndroidNotificationType.image: AndroidNotificationStyle.BigPicture,
	AndroidNotificationType.normal: AndroidNotificationStyle.Default,
};

@immutable
class AndroidNotification {
	const AndroidNotification.note([bool root = false]) :
		importance = Importance.High,
		priority = Priority.High,
		style = AndroidNotificationType.normal,
		color = RamazColors.BLUE,
		channelId = "notes",
		channelName = "Notes",
		channelDescription = "Reminders when notes are due.",
		groupId = "notes",
		playSound = true,
		shouldVibrate = true,
		isGroupSummary = root,
		showChannelBadge = true,
		icon = null,
		styleInfo = null,
		showLight = true;

	final Importance importance;
	final Priority priority;

	final AndroidNotificationType style;
	final StyleInformation styleInfo;

	final Color color;
	final String channelId, channelName, channelDescription, icon, groupId;
	final bool playSound, shouldVibrate, isGroupSummary, showChannelBadge, showLight;

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
	);
}

@immutable
class IOSNotification {
	static const IOSNotification note = IOSNotification(
		showBadge: true,
		playSound: true
	);

	final bool showBadge, playSound;

	const IOSNotification({
		@required this.showBadge,
		@required this.playSound
	});

	IOSNotificationDetails get details => IOSNotificationDetails(
		presentAlert: true,
		presentSound: playSound,
		presentBadge: showBadge,
	);
}

@immutable 
class Notification {
	final int id = 0;
	final String title, message;
	final NotificationDetails details;

	Notification({
		@required this.title,
		@required this.message,
		@required AndroidNotification android,
		@required IOSNotification ios,
	}) : details = NotificationDetails(
			android.details, ios.details,
		);

	Notification.note({
		@required this.title,
		@required this.message,
		bool root = false
	}) : 
		details = NotificationDetails(
			AndroidNotification.note(root).details, IOSNotification.note.details,	
		);
}

class Notifications {
	static final plugin = FlutterLocalNotificationsPlugin()
		..initialize(
			InitializationSettings(
				AndroidInitializationSettings(
					"@mipmap/ic_launcher"  // default icon of app
				),
				IOSInitializationSettings(),  // defaults are good
			)
		);

	static void sendNotification(Notification notification) => plugin.show(
		notification.id, 
		notification.title, 
		notification.message, 
		notification.details,
	);

	static void scheduleNotification({
		@required Notification notification,
		@required DateTime date, 
	}) => plugin.schedule(
		notification.id,
		notification.title,
		notification.message,
		date,
		notification.details,
		androidAllowWhileIdle: true,
	);

	static void cancelAll() => plugin.cancelAll();
}
