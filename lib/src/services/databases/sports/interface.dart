import "package:ramaz/data.dart";
export "package:ramaz/data.dart";

/// Defines methods for the sports data.
/// 
/// Sports are split by school year. 
abstract class SportsInterface {
	/// Gets all the sports games for this year. 
	Future<List<Json>> getAll();

	/// Sets the sports games for this year.
	Future<void> setAll(List<Json> json);
}
