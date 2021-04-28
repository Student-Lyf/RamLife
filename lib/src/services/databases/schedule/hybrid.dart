import "../hybrid.dart";

import "implementation.dart";
import "interface.dart";

/// Handles user data in the cloud and on the device. 
/// 
/// Courses are downloaded one-by-one after sign-in. However, which courses to 
/// download is unknown until the user profile is parsed. Therefore, [signIn]
/// is left empty, and the logic should instead go to middleware.
// ignore: lines_longer_than_80_chars
class HybridSchedule extends HybridDatabase<ScheduleInterface> implements ScheduleInterface {
	@override
	final ScheduleInterface cloud = CloudSchedule();

	@override
	final ScheduleInterface local = LocalSchedule();

	@override
	Future<void> signIn() async { }

	@override
	Future<Map> getCourse(String id) async {
		Map? result = await local.getCourse(id);
		if (result == null) {
			final Map course = (await cloud.getCourse(id))!;
			result = course;
			await local.setCourse(id, result);
		}
		return result;
	}

	@override
	Future<void> setCourse(String id, Map json) async {
		await cloud.setCourse(id, json);
		await local.setCourse(id, json);
	}
}
