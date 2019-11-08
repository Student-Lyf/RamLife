import "package:flutter/foundation.dart";

import "times.dart";

enum Scope {calendar, schedule}

const Map<String, Scope> stringToScope = {
	"calendar": Scope.calendar,
	"schedule": Scope.schedule,
};

const Map<Scope, String> scopeToString = {
	Scope.calendar: "calendar",
	Scope.schedule: "schedule",
};

@immutable
class Admin {
	final String email, name;
	final List<Scope> scopes;
	final List<Special> specials;

	const Admin ({
		this.email, 
		this.name, 
		this.scopes, 
		this.specials
	});

	Admin.fromJson(Map<String, dynamic> json) :
		email = json ["email"],
		name = json ["name"],
		scopes = [
			for (dynamic scope in json ["scopes"])
				stringToScope [scope]
		],
		specials = [
			for (dynamic special in json ["specials"])
				Special.fromJson (Map<String, dynamic>.from(special))
		];

	Map<String, dynamic> toJson() => {
		"email": email,
		"name": name,
		"scopes": [
			for (final Scope scope in scopes)
				scopeToString [scope]
		],
		"specials": [
			for (final Special special in specials)
				special.toJson(),
		]
	};
}
