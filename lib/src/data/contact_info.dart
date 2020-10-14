import "package:meta/meta.dart";

class ContactInfo {
	final String name;
	final String email;
	final String phoneNumber;

	ContactInfo({
		@required this.name,
		@required this.email,
		@required this.phoneNumber,
	});

	ContactInfo.fromJson(Map<String, dynamic> json) : 
		name = json ["name"],
		email = json ["email"],
		phoneNumber = json ["phoneNumber"];
}
