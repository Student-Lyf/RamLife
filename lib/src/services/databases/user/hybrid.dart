import '../../../../services.dart';
import "../hybrid.dart";

import "implementation.dart";
import "interface.dart";

/// Handles user data in the cloud and on the device. 
/// 
/// User profile is loaded once, on sign-in. Once this is complete, 
/// the full profile is always assumed to be on-device. 
class HybridUser extends HybridDatabase implements UserInterface {
	@override
	final UserInterface cloud = CloudUser();

	@override
	final UserInterface local = LocalUser();

	@override
	Future<void> signIn() async {
		final Map userData = await cloud.getProfile();
		print("Cloud");
		await local.setProfile(userData);
		print("Local");
		await Services.instance.prefs.setLastUpdated("user");
		print("User data updated");
	}

	@override
	Future<Map> getProfile() => local.getProfile();

	@override
	Future<void> setProfile(Map json) async {
		await cloud.setProfile(json);
		await local.setProfile(json);
	}
}
