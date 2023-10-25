import "../../firestore.dart";
import "../../idb.dart";

import "interface.dart";

/// Handles sports data in the cloud. 
/// 
/// Sports games are in documents by school year. See [schoolYear] for how that
/// is determined. Each document has a `games` field with a list of games.
class CloudSports implements SportsInterface {
	/// The collection for sports games.
	static final CollectionReference<Json> sports = Firestore
		.instance.collection("sports2");

	/// The current school year. 
	/// 
	/// For example, in the '20-'21 school year, this returns `2020`.
	static int get schoolYear {
		final now = DateTime.now();
		final currentYear = now.year;
		final currentMonth = now.month;
		return currentMonth > 7 ? currentYear : currentYear - 1;
	}

	/// The document for the current year. 
	static DocumentReference<Json> get gamesDocument => 
		sports.doc(schoolYear.toString());

	@override
	Future<List<Json>> getAll() async {
		final json = await gamesDocument
			.throwIfNull("Could not find sports games for this year");
		return List<Json>.from(json ["games"]);
	}

	@override
	Future<void> setAll(List<Json> json) => gamesDocument.set({"games": json});
}

/// Handles sports data in the on-device database.
/// 
/// Each sports game is another entry in the sports table. For compatibility
/// with the cloud database, sports are updated in batch.  
class LocalSports implements SportsInterface {
	@override
	Future<List<Json>> getAll() => Idb.instance.getAll(Idb.sportsStoreName);

	@override
	Future<void> setAll(List<Json> json) async {
		await Idb.instance.clearObjectStore(Idb.sportsStoreName);
		for (final game in json) {
			await Idb.instance.update(storeName: Idb.sportsStoreName, value: game);
		}
	}
}
