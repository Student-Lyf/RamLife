/// A class that can serialize itself to JSON.
/// 
/// All dataclasses that will be exported to the database should 
/// extend this class. 
abstract class Serializable {
	/// Provides a const constructor.
	const Serializable();

	/// This object in JSON form.
	Map<String, dynamic> get json;
}