// ignore_for_file: directives_ordering

import "firestore.dart";
import "idb.dart";
import "service.dart";  

import "databases/hybrid.dart";

import "databases/user/hybrid.dart";
import "databases/schedule/hybrid.dart";

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
class Database extends Service {
	/// The cloud database, using Firebase's Cloud Firestore. 
	final Firestore firestore = Firestore();

	/// The local database. 
	final Idb idb = Idb();

	/// The user data manager. 
	final HybridUser user = HybridUser();

	/// The schedule data manager
	final HybridSchedule schedule = HybridSchedule();

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
	}
}

// calendarMonth(month)
// schedule
// reminders
// updateReminder
// deleteReminder
// sports
