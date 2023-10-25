import "types.dart";

/// Holds personal information about the user. 
/// 
/// While [name] and [email] can be read from the authentication service, 
/// bundling them together in the user object can be useful too. However, 
/// this data is retrieved from the database, which needs the user's email,
/// so the authentication service is still needed for that. 
class ContactInfo {
	/// The user's name.
	final String name;

	/// The user's email.
	final String email;

	/// The user's phone number. 
	/// 
	/// This is filled in voluntary by the user, and cannot be retrieved from the 
	/// database. So this field will start off null, and be populated over time. 
	final String? phoneNumber;

	/// Bundles personal info about the user. 
	ContactInfo({
		required this.name,
		required this.email,
		this.phoneNumber,
	});

	/// Creates a contact from JSON. 
	ContactInfo.fromJson(Json json) : 
		name = json ["name"],
		email = json ["email"],
		phoneNumber = json ["phoneNumber"];
}
