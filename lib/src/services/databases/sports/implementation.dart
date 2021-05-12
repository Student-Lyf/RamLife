import "../../firestore.dart";
import "../../idb.dart";

import "interface.dart";

/// Handles sports data in the cloud. 
/// 
/// Sports games are in documents by school year. See [schoolYear] for how that
/// is determined. Each document has a `games` field with a list of games.
class CloudSports implements SportsInterface {
	/// The collection for sports games.
	static final CollectionReference<Map> sports = Firestore.instance
		.collection("sports");

	/// The current school year. 
	/// 
	/// For example, in the '20-'21 school year, this returns `2020`.
	static int get schoolYear {
		final DateTime now = DateTime.now();
		final int currentYear = now.year;
		final int currentMonth = now.month;
		return currentMonth > 7 ? currentYear : currentYear + 1;
	}

	/// The document for the current year. 
	static DocumentReference<Map> get gamesDocument => 
		sports.doc(schoolYear.toString());

	@override
	Future<List<Map>> getAll() async {
		final Map json = await gamesDocument
			.throwIfNull("Could not find sports games for this year");
		return List<Map>.from(json ["games"]);
	}

	@override
	Future<void> setAll(List<Map> json) => gamesDocument.set({"games": json});
}

/// Handles sports data in the on-device database.
/// 
/// Each sports game is another entry in the sports table. For compatibility
/// with the cloud database, sports are updated in batch.  
class LocalSports implements SportsInterface {
	@override
	Future<List<Map>> getAll() => Idb.instance.getAll(Idb.sportsStoreName);

	@override
	Future<void> setAll(List<Map> json) async {
		for (final Map game in json) {
			await Idb.instance.update(storeName: Idb.sportsStoreName, value: game);
		}
	}
}
