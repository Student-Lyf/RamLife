import "../hybrid.dart";

import "implementation.dart";
import "interface.dart";

/// Handles reminders in the cloud and on the device. 
/// 
/// Reminders are downloaded after sign-in, and are updated locally and online.
// ignore: lines_longer_than_80_chars
class HybridReminders extends HybridDatabase<RemindersInterface> implements RemindersInterface {
	/// Bundles the reminder data in the cloud and device.
	HybridReminders() : super(cloud: CloudReminders(), local: LocalReminders());

	@override
	Future<void> signIn() async {
		for (final Map reminder in await cloud.getAll()) {
			await local.set(reminder);
		}
	}

	@override
	Future<List<Map>> getAll() => local.getAll();

	@override
	Future<void> set(Map json) async {
		await cloud.set(json);
		await local.set(json);
	}

	@override
	Future<void> delete(String id) async {
		await cloud.delete(id);
		await local.delete(id);
	}
}
