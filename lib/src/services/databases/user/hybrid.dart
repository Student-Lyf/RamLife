import "../hybrid.dart";

import "cloud.dart";
import "interface.dart";
import "local.dart";

/// Handles user data in the cloud and on the device. 
/// 
/// User profile is loaded once, on sign-in. Once this is complete, 
/// the full profile is assumed to be on-device. 
class HybridUser extends HybridDatabase implements UserInterface {
	/// Bundles user data from the device and the cloud.
	HybridUser() : super(
		local: LocalUser(),
		cloud: CloudUser(),
	);

	@override
	Future<void> signIn() async {
		final Map userData = await cloud.getUser();
		await local.setUser(userData);
	}

	@override
	Future<Map> getUser() => local.getUser();

	@override
	Future<void> setUser(Map json) async {
		await cloud.setUser(json);
		await local.setUser(json);
	}
}
