import "package:firestore/data.dart";
import "package:firestore/helpers.dart";

/// A collection of functions to read faculty data.
/// 
/// No function in this class actually performs logic on said data, just returns
/// it. This helps keep the program modular, by separating the data sources from
/// the data indexing.
class FacultyReader {
	/// Maps faculty IDs to their respective [User] objects.
	static Future<Map<String, User>> getFaculty() async => {
		await for(final Map<String, dynamic> row in csvReader(DataFiles.faculty))
			row ["ID"]: User(
				id: row ["ID"],
				email: row ["E-mail"].toLowerCase(),
				first: row ["First Name"],
				last: row ["Last Name"],
			)
	};
}
