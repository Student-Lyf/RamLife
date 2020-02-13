import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A DataModel that keeps the state of the user's reminders. 
/// 
/// This data model abstracts all operations that have to do with reminders, 
/// and all other parts of the app that want to operate on reminders should use
/// this data model.
// ignore: prefer_mixin
class Reminders with ChangeNotifier {
	final Reader _reader;

	/// The reminders for the user.
	List<Reminder> reminders;

	/// The reminders that apply for this period. 
	/// 
	/// This is managed by the Schedule data model.
	List<int> currentReminders;

	/// The reminders that apply for next period.
	/// 
	/// This is managed by the Schedule data model.
	List<int> nextReminders;

	/// Reminders that applied for previous periods. 
	/// 
	/// These reminders will be marked for deletion if they do not repeat.
	List<int> readReminders;

	/// Creates a Reminders data model. 
	/// 
	/// This automatically calls [setup].
	Reminders(this._reader) {setup();}

	/// Initializes this data model.
	/// 
	/// This function should be called any time completely new data is available.
	void setup() {
		final Map<String, dynamic> data = _reader.remindersData;
		readReminders = List<int>.from(data ["read"] ?? []);
		reminders = [
			for (final json in data ["reminders"] ?? [])
				Reminder.fromJson(json)
		];
		notifyListeners();
	}

	/// Whether any reminder applies to the current period.
	bool get hasReminder => currentReminders.isNotEmpty;
		
	/// Marks a reminder as "shown".
	/// 
	/// It will then be marked for deletion if it does not repeat.
	/// See [readReminders] and [cleanReminders] for details.
	void markShown(int index) {
		if (readReminders.contains(index)) {
			return;
		}
		readReminders.add(index);
		cleanReminders();
		updateReminders();
	}

	/// Gets all reminders that apply to the a given period. 
	/// 
	/// This method is a wrapper around [Reminder.getReminders], and should only
	/// be called by an object with access to the relevant period. 
	List<int> getReminders({
		@required String subject,
		@required String period,
		@required Letters letter,
	}) => Reminder.getReminders(
		reminders: reminders,
		subject: subject,
		letter: letter,
		period: period,
	).toList();

	/// Saves all reminders to the device and the cloud. 
	/// 
	/// This method sets [Reader.remindersData] and calls 
	/// [Firestore.saveReminders].
	void saveReminders() {
		final List<Map<String, dynamic>> json = [
			for (final Reminder reminder in reminders ?? [])
				reminder.toJson()
		];
		_reader.remindersData = {
			"reminders": json,
			"read": readReminders ?? [],
		};
		Firestore.saveReminders(json);
	}

	/// Checks if any reminders have been modified and removes them. 
	/// 
	/// This makes sure that any reminders in [currentReminders], 
	/// [nextReminders], and [readReminders] are all up-to-date. 
	void verifyReminders(int changedIndex) {
		final List<List<int>> reminderLists = [
			currentReminders, 
			nextReminders, 
			readReminders
		];
		for (final List<int> remindersList in reminderLists) {
			int toRemove;
			for (final int index in remindersList ?? []) {
				if (index == changedIndex) {
					toRemove = index;
					break;
				}
			}
			if (toRemove != null) {
				remindersList.remove(toRemove);
			}
		}
	}

	/// Runs errands whenever reminders have changed. 
	/// 
	/// Does the following: 
	/// 
	/// 1. Runs [verifyReminders] (if a reminder has changed and not simply added).
	/// 2. Runs [saveReminders].
	/// 3. Calls [notifyListeners].
	void updateReminders([int changedIndex]) {
		if (changedIndex != null) {
			verifyReminders(changedIndex);
		}
		saveReminders();
		notifyListeners();
	}

	/// Replaces a reminder at a given index. 
	void replaceReminder(int index, Reminder reminder) {
		if (reminder == null) {
			return;
		}
		reminders
			..removeAt(index)
			..insert(index, reminder);
		updateReminders(index);
	}

	/// Adds a reminder to the reminders list. 
	/// 
	/// Use this method instead of simply `reminders.add` to 
	/// ensure that [updateReminders] is called. 
	void addReminder(Reminder reminder) {
		if (reminder == null) {
			return;
		}
		reminders.add(reminder);
		updateReminders();
	}

	/// Deletes the reminder at a given index.
	/// 
	/// Use this insead of `reminders.removeAt` to ensure that 
	/// [updateReminders] is called.
	void deleteReminder(int index) {
		reminders.removeAt(index);
		updateReminders(index);
	}

	/// Deletes expired reminders. 
	/// 
	/// This method searches all reminders in [readReminders] for a reminder that
	/// does not repeat and has been shown already (ie, in [currentReminders]), 
	/// then calls [deleteReminder] on them. 
	void cleanReminders() {
		for (final Reminder reminder in [
			for (final int index in readReminders)
				if (!reminders [index].time.repeats && !currentReminders.contains(index))
					reminders [index]
		]) {
			deleteReminder(reminders.indexOf(reminder));
		}
	}
}
