/// Bundles cloud and local databases together. 
///
/// T represents the type of data being stored.
abstract class HybridDatabase<T> {
  /// The cloud database for this data.
  final T cloud;

  /// The local database for this data.
  final T local;

  /// Bundles two databases into one.
  HybridDatabase({
    required this.cloud,
    required this.local,
  });

  /// Initializes any data necessary for sign-in
  Future<void> signIn();
}
