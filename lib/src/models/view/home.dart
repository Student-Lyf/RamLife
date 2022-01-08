import "package:flutter/foundation.dart";

import "package:ramaz/models.dart";
import "package:ramaz/services.dart";

/// A view model for the dashboard page. 
/// 
/// This model doesn't actually do much, it just listens to any data models
/// that are relevant to the dashboard. Because we're using [ChangeNotifier], 
/// as its the only [Listenable] with a [dispose] method, we can't simply use 
/// [Listenable.merge]. 
/// 
/// Additionally, the data models being listened to here will be disposed after
/// signing in and will be unusable. That's why we can't simply pass in a data 
/// model. Instead, we have to reference it through [Models], which will always
/// have an up-to-date instance. 
// ignore: prefer_mixin
class DashboardModel with ChangeNotifier {
	/// The underlying data representing this widget.
	final ScheduleModel schedule = Models.instance.schedule;

	/// The reminders data model. 
	final Reminders reminders = Models.instance.reminders;

	/// The sports data model. 
	final Sports sports = Models.instance.sports;

	/// Listens to [ScheduleModel] (and by extension, [Reminders]) and [Sports].
	DashboardModel() {
		schedule.addListener(notifyListeners);
		sports.addListener(notifyListeners);
	}

	// Do not attempt to clean up this code by using a list. 
	// 
	// These models may be disposed, and the new instance from [Models] should 
	// be used instead. 
	@override
	void dispose() {
		schedule.removeListener(notifyListeners);
		sports.removeListener(notifyListeners);
		super.dispose();
	}

	/// Refreshes the database. 
	/// 
	/// This only updates the calendar and sports games, not the user profile. To
	/// update user data, sign out and sign back in.
	Future<void> refresh(VoidCallback onFailure) async {
		try {
			await Services.instance.database.user.signIn();
			await Services.instance.database.calendar.signIn();
			await Services.instance.database.sports.signIn();
			await schedule.initCalendar();
		} catch (error) {  // ignore: avoid_catches_without_on_clauses
			// We just want to allow the user to retry. But still rethrow.
			onFailure();
			rethrow;
		}
	}
}
