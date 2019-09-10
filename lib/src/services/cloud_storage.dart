import "package:firebase_storage/firebase_storage.dart";
import "dart:io" show File;

class CloudStorage {
	static final StorageReference root = FirebaseStorage().ref();
	static const String delimeter = ", ";

	final String dir;
	final Map<String, Map<String, String>> metadata = {};

	CloudStorage(this.dir);

	Future<List<String>> get publications async => (await root.getMetadata())
		.customMetadata ["names"]
		.split(delimeter);

	Future<Map<String, String>> getMetadata(String publication) async => 
		(await root.child(publication).getMetadata()).customMetadata;

	Future<List<String>> getRecents(String publication) async =>
		await (await root.child(publication).getMetadata())
			.customMetadata ["recents"]
			.split(delimeter);

	Future<List<String>> getAllIssues(String publication) async => 
		await (await root.child(publication).getMetadata())
			.customMetadata ["all"]
			.split(delimeter);

	Future<String> getIssue(String path) async {
		final String filename = "$dir/$path.pdf";
		await root.child(path).writeToFile(File(filename)).future;
		return filename;
	}

	Future<String> getPublicationImage(String publication) async {
		final String filename = "$dir/$publication-image.png";
		await root.child("$publication-image.png").writeToFile(File(filename)).future;
		return filename;
	}
}
