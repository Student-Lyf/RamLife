import "../hybrid.dart";

import "implementation.dart";
import "interface.dart";

/// Handles sports in the cloud and on the device. 
/// 
/// Sports are downloaded after sign-in, and should be updated on a weekly 
/// basis. They should also be manually refreshable.
// ignore: lines_longer_than_80_chars
class HybridSports extends HybridDatabase<SportsInterface> implements SportsInterface {
	/// Bundles the sports data from the cloud and on the device. 
	HybridSports() : super(cloud: CloudSports(), local: LocalSports());

	@override
	Future<void> signIn() async => local.setAll(await cloud.getAll());

	@override
	Future<List<Map>> getAll() => local.getAll();

	@override
	Future<void> setAll(List<Map> json) async {
		await cloud.setAll(json);
		await local.setAll(json);
	}
}
