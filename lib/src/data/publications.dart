import "package:flutter/foundation.dart" show immutable, required;

/// A publication club (such as Rampage)
@immutable
class Publication {
	/// Returns a list of [Publication]s from a list of JSON objects.
	/// 
	/// See [Publication.fromJson] for details.
	static List<Publication> getList(List<Map<String, dynamic>> data) => [
		for (dynamic json in data) 
			Publication.fromJson(json)
	];

	/// THe metadata for this publication.
	final PublicationMetadata metadata;

	/// The name of this publication.
	final String name;

	/// A list of all the issues downloaded for this publication.
	/// 
	/// This includes recent and outdated issues. It can be safely assumed 
	/// that any path listed in here is present in the filesystem.
	final Set<String> downloadedIssues;	

	/// A const constructor for this class.
	const Publication({
		@required this.name,
		@required this.downloadedIssues,
		@required this.metadata,
	});

	/// Returns a new [Publication] from a JSON object.
	/// 
	/// The JSON must have: 
	/// 
	/// 	- a `name` field that is a string. See [name].
	/// 	- an `issues` field that is a list of strings. See [downloadedIssues].
	/// 	- a `metadata` field that is JSON. See [PublicationMetadata.fromJson].
	/// 
	Publication.fromJson(Map<String, dynamic> json) :
		name = json ["name"],
		downloadedIssues  = Set<String>.from(json ["issues"]),
		metadata = PublicationMetadata.fromJson(
			Map<String, dynamic>.from(json ["metadata"])
		);

	/// Returns a JSON representation of this publication.
	Map<String, dynamic> toJson() => {
		"name": name,
		"issues": List.from(downloadedIssues),
		"metadata": metadata.toJson(),
	};
}

/// Metadata about a publication.
/// 
/// Metadata includes things like:
/// 
/// 	- a label image,
/// 	- a list of recent issues,
/// 	- a list of all issues, and
/// 	- a description of the publication.
/// 
@immutable 
class PublicationMetadata {
	/// Returns a collection of issues sorted by month.
	/// 
	/// See [PublicationMetadata.issuesByMonth] for usage.
	static Map<int, Map<int, List<String>>> getIssuesByMonth(List<String> issues) {
		issues.sort();
		final Map<int, Map<int, List<String>>> result = {};
		for (final String issue in issues) {
			final List<String> date_parts = issue.substring(
				issue.lastIndexOf("/") + 1, issue.length - 4
			).split("_");
			final int year = int.parse(date_parts [0]);
			final int month = int.parse(date_parts [1]);
			if (!result.containsKey(year))
				result [year] = {};
			List<String> issuesForMonth = result [year] [month];
			if (issuesForMonth == null) {
				issuesForMonth = [];
				result [year] [month] = issuesForMonth;
			} 
			issuesForMonth.add(issue);
		}
		return result;
	}

	/// All issues available for this publication.
	/// 
 	/// These paths can be downloaded from Firebase Cloud Storage.
	final List<String> issues;

	/// All issues for this publication sorted by year and month.
	/// 
	/// The keys are years and the values are maps where the keys 
	/// are months and the values are issues for that month.
	/// 
	/// For example: `issuesByMonth [2019] [0]` will return all issues 
	/// for January 2019.
	final Map<int, Map<int, List<String>>> issuesByMonth;
	
	/// A description of this publication.
	final String description;

	/// A constructor for this class.
	/// 
	/// [issuesByMonth] will be automatically initialized. See [getIssuesByMonth].
	PublicationMetadata({
		@required this.issues,
		@required this.description,
	}) : issuesByMonth = getIssuesByMonth(issues);

	/// Returns a new metadata instance from a JSON object.
	/// 
	/// The JSON must have: 
	/// 	- a `description` field that is a string. See [description].
	/// 	- an `issues` field that is a list of strings. See [issues].
	/// 
	/// [issuesByMonth] will be automatically initialized. See [getIssuesByMonth].
	PublicationMetadata.fromJson(Map<String, dynamic> json) :
		issues = List<String>.from(json ["allIssues"].split(", ")),
		description = json ["description"] as String,
		issuesByMonth = getIssuesByMonth(
			List<String>.from(json ["allIssues"].split(", "))
		);

	@override
	operator == (dynamic other) => other is PublicationMetadata &&
		issues == other.issues &&
		description == other.description;

	/// Returns a JSON representation of this instance.
	Map<String, dynamic> toJson() => {
		"description": description,
		"allIssues": issues.join (", "),
	};
}
