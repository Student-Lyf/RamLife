import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";
import "package:ramaz/services_collection.dart";

@immutable
class PublicationIssues implements Comparable<PublicationIssues> {
	static const List<String> months = [
		"Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	];

	static String getDate(String filename) {
		final date_part = filename.substring(filename.lastIndexOf("/") + 1, filename.length - 4);
		final List<String> date_parts = date_part.split("_");
		final int month = int.parse(date_parts [1]);
		final int date = int.parse(date_parts [2]);
		return "${months [month]} $date";
	}

	final int month;
	final int year;
	final List<String> issues;

	const PublicationIssues({
		@required this.month,
		@required this.year,
		@required this.issues,
	});

	@override
	int compareTo(PublicationIssues other) {
		if (year < other.year) return -1;
		else if (year == other.year) {
			if (month == other.month) return 0;
			else if (month < other.month) return -1;
			else return 1;
		} else return 1;
	}

	@override 
	String toString() => "${months [month]} $year";
}

class PublicationsModel with ChangeNotifier {
	final List<Publication> publications;
	final ServicesCollection services;
	final CloudStorage storage;

	PublicationsModel(this.services) :
		storage = services.storage,
		publications = Publication.getList(services.reader.publications);

	Future<void> updatePublications() async {
		final Map<String, int> publicationDetails = Map.fromIterable(
			publications,
			key: (publication) => publication.name,
			value: (publication) => publication,
		);

		List<int> changed = [];
		final List<String> publicationList = await storage.publications;
		for (final String publication in publicationList) {
			final PublicationMetadata metadata = PublicationMetadata.fromJson(
				await storage.getMetadata(publication)
			);

			final int index = publicationDetails [publication];
			if (index == null) {
				publications.add(
					Publication(
						name: publication,
						metadata: metadata,
						issues: await storage.getRecents(publication),
					)
				);
			} else {
				final Publication pub = publications [index];
				if (pub.metadata != metadata) {
					publications [publicationDetails [publication]] = Publication(
						name: publication,
						issues: pub.issues,
						metadata: metadata,
					);
					changed.add(index);
				}
			}
		}

		if (changed.isNotEmpty) {
			for (final int index in changed) {
				await updateRecents(publications [index]);
			}
		}
		notifyListeners();
	}

	Future<void> updateRecents(Publication publication) async {
		final List<String> recents = await storage.getRecents(publication.name);
		for (final String issuePath in recents) {
			if (publication.issues.contains(issuePath)) continue;

			final String issue = await storage.getIssue(issuePath);
			publication.issues.add(issue);
		}
		notifyListeners();
	}

	Future<void> getMoreIssues(Publication publication) async {
		final List<String> issues = await storage.getAllIssues(publication.name);
		int count = 0;
		for (final String issuePath in issues) {
			if (publication.issues.contains(issuePath)) continue;

			final String issue = await storage.getIssue(issuePath);
			publication.issues.add(issue);
			notifyListeners();
			if (count++ == 4) break;
		}
	}

	List<PublicationIssues> getIssues(Publication publication) {
		// format for file is: publication/year_month_day.jpg
		final Map<int, List<List<String>>> years = {};
		for (final String issue in publication.issues) {
			// path/to/file.jpg => file
			final date_part = issue.substring(issue.lastIndexOf("/") + 1, issue.length - 4);
			final List<String> date_parts = date_part.split("_");
			final int year = int.parse(date_parts [0]);
			final int month = int.parse(date_parts [1]);
			List<List<String>> issuesForYear = years [year];
			if (issuesForYear == null) {
				issuesForYear = List.generate(12, (_) => []);
				years[year] = issuesForYear;
			}
			issuesForYear [month].add(issue);
		}

		final List<PublicationIssues> result = [];
		for (final MapEntry<int, List<List<String>>> entry in years.entries) {
			final int year = entry.key;
			final List<List<String>> issuesForYear = entry.value;
			for (int index = 0; index < 12; index++) {
				final List<String> issuesForMonth = issuesForYear [index];
				issuesForMonth.sort();
				result.add(
					PublicationIssues(
						year: year,
						month: index,
						issues: issuesForMonth,
					)
				);
			}
		}

		result.sort();
		return result;
	}
}
