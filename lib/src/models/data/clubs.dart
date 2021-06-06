import "package:ramaz/models.dart";
import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

import "model.dart";

/// A data model that manages data and operations for clubs.
/// 
/// This model should be usable for all users. Captains, faculty advisors, and 
/// admins have their own models. 
class Clubs extends Model{
	@override
	Future<void> init() async {
		// TODO: Get the user's current clubs
	}

	/// The user's contact info.
	ContactInfo get contact => Models.instance.user.data.contactInfo;

	/// Gets all the clubs in the database.
	Future<List<Club>> getAllClubs() async => [
		for (final Map json in await Services.instance.database.clubs.getAll())
			Club.fromJson(json)
	];

	/// Registers a user to the given club.
	Future<void> registerForClub(Club club) async {
		Models.instance.user.data.registeredClubs.add(club.id);
		club.members.add(contact);
		await Services.instance.database.clubs
			.register(club.id, contact.email, contact.toJson());
	}

	/// Unregisters a user from the given club.	
	Future<void> unregisterFromClub(Club club) async {
		Models.instance.user.data.registeredClubs.remove(club.id);
		club.members.remove(contact);
		await Services.instance.database.clubs
			.unregister(club.id, contact.email, contact.toJson());
	}
}
