/// Defines methods for the sports data.
/// 
/// Sports are split by school year. 
abstract class SportsInterface {
	/// Gets all the sports games for this year. 
	Future<List<Map>> getSports();

	/// Sets the sports games for this year.
	Future<void> setSports(List<Map> json);
}
