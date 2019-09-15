import "package:firebase_storage/firebase_storage.dart";
import "dart:io" show File, Directory;

/// An abstraction around Firebase Cloud Storage.
class CloudStorage {
	/// The Firebase Cloud Storage instance for this service
	static final StorageReference root = FirebaseStorage().ref();

	/// The separator for lists. 
	/// 
	/// Custom metadata values are restricted to being just Strings, so lists 
	/// are serialized with: `List.join(delimeter)`. 
	/// 
	/// This is a good workaround for now. If the need arises, the values can be 
	/// replaced with full JSON strings to serialize more complex data.
	static const String delimeter = ", ";

	/// The directory for publications.
	final Directory publicationDir;

	/// A constructor for this class. 
	/// 
	/// [publicationDir] is initialized here.
	CloudStorage(String path) : 
		publicationDir = Directory("$path/publications");

	/// All available publications.
	Future<List<String>> get publications async => (await root.child("issues.txt").getMetadata())
		.customMetadata ["names"]
		.split(delimeter);

	/// Returns the metadata for a given publication.
	Future<Map<String, String>> getMetadata(String publication) async => 
		await (await root.child("$publication/issues.txt").getMetadata())
			.customMetadata;

	/// Downloads an issue from Firebase Cloud Storage if needed. 
	Future<void> getIssue(String path) async {
		final String filename = getPath(path);
		await root.child(path).writeToFile(File(filename)).future;
	}

	/// Downloads the cover image for a given publication if needed.
	Future<void> getPublicationImage(String publication) async {
		final String filename = getImagePath(publication);
		final Directory publicationDir = Directory(getPath(publication));
		if (!publicationDir.existsSync())
			publicationDir.createSync(recursive: true);

		final File file = File (filename);
		if (file.existsSync()) return;
		await (root.child(publication).child("${publication.toLowerCase()}.png").writeToFile(file).future);
		return;
	}

	/// Concatenates a given path to the app's root directory.
	String getPath(String path) => "${publicationDir.path}/$path";

	/// Returns the path to an image for a given publication on the filesystem.
	String getImagePath(String name) => getPath(
		"$name/${name.toLowerCase()}.png"
	);

	/// Deletes all publication data.
	void deleteAll() {
		publicationDir.deleteSync(recursive: true);
	}
}
