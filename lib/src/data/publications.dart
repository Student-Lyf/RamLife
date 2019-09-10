import "package:flutter/foundation.dart" show immutable, required;

@immutable
class Publication {
	static List<Publication> getList(List data) {
		final List<Publication> result = [];
		for (dynamic json in data) 
			result.add(Publication.fromJson(Map<String, dynamic>.from(json)));
		return result;
	}

	final PublicationMetadata metadata;
	final List<String> issues;	
	final String name;

	const Publication({
		@required this.name,
		@required this.issues,
		@required this.metadata,
	});

	Publication.fromJson(Map<String, dynamic> json) :
		name = json ["name"],
		issues  = List<String>.from(json ["issues"]),
		metadata = PublicationMetadata.fromJson(Map<String, dynamic>.from(json ["metadata"]));

	Map<String, dynamic> toJson() => {
		"name": name,
		"issues": issues,
		"metadata": metadata.toJson(),
	};
}

@immutable 
class PublicationMetadata {
	final List<String> recents, allIssues;
	final String description, imagePath;

	const PublicationMetadata({
		@required this.recents,
		@required this.allIssues,
		@required this.description,
		@required this.imagePath,
	});

	PublicationMetadata.fromJson(Map<String, dynamic> json) :
		recents = List<String>.from(json ["recents"]),
		allIssues = List<String>.from(json ["allIssues"]),
		description = json ["description"] as String,
		imagePath = json ["imagePath"] as String;

	Map<String, dynamic> toJson() => {
		"description": description,
		"imagePath": imagePath,
		"recents": recents,
		"allIssues": allIssues,
	};

	operator == (dynamic other) => other is PublicationMetadata &&
		recents == other.recents &&
		allIssues == other.allIssues &&
		description == other.description &&
		imagePath == other.imagePath;
}
