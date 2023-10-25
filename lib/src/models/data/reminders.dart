import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

import "model.dart";

/// A DataModel that keeps the state of the user's reminders. 
/// 
/// This data model abstracts all operations that have to do with reminders, 
/// and all other parts of the app that want to operate on reminders should use
/// this data model.
// ignore: prefer_mixin
class Reminders extends Model {
	/// The reminders for the user.
	late final List<Reminder> reminders;

	/// The reminders that apply for this period. 
	/// 
	/// This is managed by the Schedule data model.
	List<int> currentReminders = [];

	/// The reminders that apply for next period.
	/// 
	/// This is managed by the Schedule data model.
	List<int> nextReminders = [];

	/// Reminders that applied for previous periods. 
	/// 
	/// These reminders will be marked for deletion if they do not repeat.
	final List<int> readReminders = [];

	@override
	Future<void> init() async {
		reminders = [
			for (final Json json in await Services.instance.database.reminders.getAll())
				Reminder.fromJson(json),
		];
	}

	/// Whether any reminder applies to the current period.
	bool get hasReminder => currentReminders.isNotEmpty;

	/// Whether any reminder applies to the next period.
	bool get hasNextReminder => nextReminders.isNotEmpty;
		
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
	}

	/// Gets all reminders that apply to the a given period. 
	/// 
	/// This method is a wrapper around [Reminder.getReminders], and should only
	/// be called by an object with access to the relevant period. 
	List<int> getReminders({
		required String? subject,
		required String? period,
		required String? dayName,
	}) => Reminder.getReminders(
		reminders: reminders,
		subject: subject,
		dayName: dayName,
		period: period,
	).toList();

	/// Checks if any reminders have been modified and removes them. 
	/// 
	/// This makes sure that any reminders in [currentReminders], 
	/// [nextReminders], and [readReminders] are all up-to-date. 
	void verifyReminders(int changedIndex) {
		final reminderLists = <List<int>>[
			currentReminders, 
			nextReminders, 
			readReminders,
		];
		for (final remindersList in reminderLists) {
			final removeIndex = remindersList.indexOf(changedIndex);
			if (removeIndex != -1) {
				remindersList.removeAt(removeIndex);
			}
		}
	}

	/// Replaces a reminder at a given index. 
	void replaceReminder(int index, Reminder? reminder) {
		if (reminder == null) {
			return;
		}
		if (reminders [index].id != reminder.id) {
			throw ArgumentError.value(
				reminder.id,  // value
				"New reminder id",  // name of value
				"New reminder ID must match old reminder ID",  // message
			);
		}
		reminders [index] = reminder;
		Services.instance.database.reminders.set(reminder.toJson());
		verifyReminders(index);
		notifyListeners();
	}

	/// Creates a new reminder. 
	void addReminder(Reminder? reminder) {
		if (reminder == null) {
			return;
		}
		reminders.add(reminder);
		Services.instance.database.reminders.set(reminder.toJson());
		notifyListeners();
	}

	/// Deletes the reminder at a given index.
	Future<void> deleteReminder(int index) async {
		final id = reminders [index].id;
		await Services.instance.database.reminders.delete(id);
		reminders.removeAt(index);
		verifyReminders(index);  // remove the reminder from the schedule
		notifyListeners();
	}

	/// Deletes expired reminders. 
	/// 
	/// This method searches all reminders in [readReminders] for a reminder that
	/// does not repeat and has been shown already (ie, in [currentReminders]), 
	/// then calls [deleteReminder] on them. 
	void cleanReminders() {
		for (final reminder in [
			for (final int index in readReminders)
				if (!reminders [index].time.repeats && !currentReminders.contains(index))
					reminders [index],
		]) {
			deleteReminder(reminders.indexOf(reminder));
		}
	}
}
