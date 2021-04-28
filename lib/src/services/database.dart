// ignore_for_file: directives_ordering

import "firestore.dart";
import "idb.dart";
import "service.dart";  

import "databases/hybrid.dart";

import "databases/calendar/hybrid.dart";
import "databases/reminders/hybrid.dart";
import "databases/schedule/hybrid.dart";
import "databases/sports/hybrid.dart";
import "databases/user/hybrid.dart";

export "databases/calendar/hybrid.dart";
export "databases/reminders/hybrid.dart";
export "databases/schedule/hybrid.dart";
export "databases/sports/hybrid.dart";
export "databases/user/hybrid.dart";

/// A wrapper around all data in all database. 
/// 
/// The database is split into 2N parts: N types of data, with a Firestore and 
/// IDB implementation for each. The local and cloud implementations are bundled
/// into [HybridDatabase]s, which we use here.
/// 
/// This is the only class that brings the [Service] paradigm into the database
/// realm, so any and all initialization must be done here. Each database is 
/// allowed to implement a [signIn] method, which will be called here. If data 
/// needs to be downloaded and cached, that's where it will be done. 
class Database extends DatabaseService {
	/// The cloud database, using Firebase's Cloud Firestore. 
	final Firestore firestore = Firestore();

	/// The local database. 
	final Idb idb = Idb();

	// ----------------------------------------------------------------
	// The data managers for each category 
	// ----------------------------------------------------------------

	/// The user data manager. 
	final HybridUser user = HybridUser();

	/// The schedule data manager
	final HybridSchedule schedule = HybridSchedule();

	/// The calendar data manager.
	final HybridCalendar calendar = HybridCalendar();

	/// The reminders data manager.
	final HybridReminders reminders = HybridReminders();

	/// The sports data manager.
	final HybridSports sports = HybridSports();

 	// ----------------------------------------------------------------

	@override
	Future<void> init() async {
		await firestore.init();
		await idb.init();
	}

	@override
	Future<void> signIn() async {
		await firestore.signIn();
		await idb.signIn();

		await user.signIn();
		await schedule.signIn();
		await calendar.signIn();
		await reminders.signIn();
		await sports.signIn();
	}

	@override
	Future<void> signOut() async {
		await firestore.signOut();
		await idb.signOut();
	}
}
