// ignore_for_file: avoid_unused_constructor_parameters
// ignore_for_file: public_member_api_docs
class Notification {
	Notification({
		dynamic title,
		dynamic message,
		dynamic android,
		dynamic ios,
	}); 

	/// The optimal configuration for a reminder notification.
	Notification.reminder({
		dynamic title,
		dynamic message,
		bool root = false
	});
}

// ignore: avoid_classes_with_only_static_members
/// An abstract wrapper around the notifications plugin. 
/// 
/// This class uses static methods to send and schedule
/// notifications.
class Notifications {
	/// Sends a notification immediately. 
	static void sendNotification(Notification notification) {}

	/// Schedules a notification for [date]. 
	/// 
	/// If [date] is in the past, the notification will go off immediately.
	static void scheduleNotification({
		Notification notification,
		DateTime date, 
	}) {}

	/// Cancels all scheduled notifications, as well as 
	/// dismissing all present notifications. 
	static void cancelAll() {} 
}
