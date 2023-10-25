import "../hybrid.dart";

import "implementation.dart";
import "interface.dart";

/// Handles user data in the cloud and on the device. 
/// 
/// User profile is loaded once, on sign-in. Once this is complete, 
/// the full profile is always assumed to be on-device. 
class HybridUser extends HybridDatabase<UserInterface> implements UserInterface {
	@override
	final UserInterface cloud = CloudUser();

	@override
	final UserInterface local = LocalUser();

	@override
	Future<void> signIn() async {
		final userData = await cloud.getProfile();
		await local.setProfile(userData);
	}

	@override
	Future<Json> getProfile() => local.getProfile();

	@override
	Future<void> setProfile(Json json) async {
		await cloud.setProfile(json);
		await local.setProfile(json);
	}
}
