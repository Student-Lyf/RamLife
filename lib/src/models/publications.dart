import "package:flutter/foundation.dart";

import "package:ramaz/data.dart";
import "package:ramaz/services.dart";
import "package:ramaz/services_collection.dart";

class PublicationsModel with ChangeNotifier {
	final List<Publication> publications;
	final ServicesCollection services;
	final CloudStorage storage;
	final Reader reader;

	String downloading;

	PublicationsModel(this.services) :
		storage = services.storage,
		reader = services.reader,
		publications = Publication.getList(services.reader.publications) 
	{
		if (publications.isEmpty)
			updatePublications();
	}

	Future<Publication> getPublication(String name) async {
		final Publication publication = Publication(
			name: name,
			downloadedIssues: Set<String>(),
			metadata: PublicationMetadata.fromJson(
				await storage.getMetadata(name),
			),
		);
		await storage.getPublicationImage(name);
		return publication;
	}

	void savePublications() => reader.publications = [
		for (final Publication publication in publications)
			publication.toJson()
	];

	Future<String> getIssue(Publication publication, String issue) async {
		downloading = issue;
		notifyListeners();
		if (!publication.downloadedIssues.contains(issue)) {
			await storage.getIssue(issue);
			publication.downloadedIssues.add(issue);
			savePublications();
		}
		downloading = null;
		notifyListeners();
		return storage.getPath(issue);
	}

	void replacePublication(Publication publication) {
		final Map<String, int> indices = publications.asMap().map(
			(int index, Publication publication) => MapEntry (
				publication.name, index,
			)
		);
		final int index = indices [publication.name];
		if (index == null) throw ArgumentError.value(
			publication,
			"publication",
			"${publication.name} was not found in the list of downloaded publications."
		);

		final Publication other = publications[index];
		if (publication.metadata == other.metadata) return;

		publication.downloadedIssues.addAll(other.downloadedIssues);

		publications [index] = publication;
		notifyListeners();
	}

	void updatePublication(String name) async {
		replacePublication(
			await getPublication(name)
		);
		savePublications();
	}

	Future<void> updatePublications() async {
		final Map<String, int> indices = publications.asMap().map(
			(int index, Publication publication) => MapEntry (
				publication.name, index,
			)
		);
		for (final String name in await storage.publications) {
			if (indices.containsKey(name))
				updatePublication(name);
			else {
				publications.add(await getPublication(name));
				notifyListeners();
			}
		}
		savePublications();
	}
}
