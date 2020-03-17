import "package:flutter/foundation.dart" show required;

import "package:ramaz/services.dart";
import "package:ramaz/models.dart";
import "package:ramaz/data.dart";

/// A class to wrap the services library into a singleton
class ServicesCollection {
	/// The [Reader] for this collection.
	final Reader reader;

	/// The [Preferences] for this collection.
	final Preferences prefs;

	/// A [Reminders] data model.
	Reminders reminders;

	/// A [Schedule] data model.
	Schedule schedule;

	/// A [Sports] data model.
	Sports sports;

	/// The admin data model for this admin. 
	AdminModel admin;

	/// Creates a new services collection. 
	/// 
	/// Generally, there should only be one of these, 
	/// as they manage their own services.
	ServicesCollection({
		@required this.reader,
		@required this.prefs,
	});

	/// Completely refresh the user's schedule, simulating the login sequence.
	Future<void> refresh() async {
		final String email = await Auth.email;
		if (email == null) {
			throw StateError(
				"Cannot refresh schedule because the user is not logged in."
			);
		}
		await initOnLogin(email, first: false);
		reminders.setup();
		schedule.setup(reader);
		sports.setup(refresh: true);
	}

	/// Downloads the calendar and calls appropriate methods. 
	Future<void> updateCalendar() async {
		reader.calendarData = await Firestore.getCalendar(download: true);
		schedule.setup(reader);
	}

	/// Refreshes the list of sports games. 
	Future<void> updateSports() async {
		reader.sportsData = await Firestore.sports;
		sports.setup(refresh: true);
	}

	/// Initializes the collection.
	/// 
	/// This function is a safety! In the event a file is unavailable, the 
	/// try-catch in `main` will throw an error. After the files are verifiably
	/// available, this function is called. 
	///
	/// Use this function to initialize anything that requires a file.
	/// 
	/// Also sets the admin data model for the user. If the user is not an admin 
	/// (as dictated by FirebaseAuth's custom claims), then [admin] becomes null. 
	Future<void> init() async {
		reminders = Reminders(reader);
		schedule = Schedule(reader, reminders: reminders);
		sports = Sports(reader);
		if (await Auth.isAdmin) {
			reader.adminData = await Firestore.admin ?? {};
			admin = AdminModel(this, await Auth.adminScopes);
		}
		// Register for FCM notifications. 
		// We don't care when this happens
		// ignore: unawaited_futures 
		Future(
			() async {
				await FCM.registerNotifications(
					{
						"refresh": refresh,
						"updateCalendar": updateCalendar,
						"updateSports": updateSports,
					}
				);
				await FCM.subscribeToTopics();
			}
		);
	}

	/// The login protocol. 
	/// 
	/// Downloads data from Firebase, and serializes them to [reader].
	/// If the user is actually logging in (as opposed to a full refresh),
	/// then [init] will be called to initialize the data models. 
	Future<void> initOnLogin(String email, {bool first = true}) async {
		// Save and initialize the student to get the subjects
		final Map<String, dynamic> studentData = await Firestore.student;
		final Student student = Student.fromJson(studentData);		

		// save the data
		reader
			..adminData = null
			..studentData = studentData
			..subjectData = await Firestore.getClasses(student.getIds())
			..calendarData =  await Firestore.getCalendar()
			..sportsData = await Firestore.sports
			..remindersData = {
				"reminders": await Firestore.reminders,
				"read": [],
			};

		if (first) {
			await init();
		}
	}
}
