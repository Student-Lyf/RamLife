/// Bundles cloud and local databases together. 
///
/// The app uses an online and offline database for two reasons. 
/// 
/// 1. So the app can work offline
/// 2. So we don't hit quotas on our cloud database. 
/// 
/// [T] is an interface that describes what data a class needs to access for a
/// given category of data. [T] should be implemented twice, for online and 
/// offline functionality. This class serves to tie them together. 
/// 
/// Simply extend this class and implement [T] and you now have a database that
/// can access both the cloud and the on-device database. Implement each method
/// of [T] by choosing which source to use for the data. 
/// 
/// The [signIn] method allows data to flow from the online to local database. 
/// Use it to initialize any data the app expects be on-device. 
abstract class HybridDatabase<T> {
  /// The interface for this data in the online database.
  final T cloud;

  /// The interface for this data in the offline database.
  final T local;

  /// Bundles two databases into one.
  HybridDatabase({
    required this.cloud,
    required this.local,
  });

  /// Initializes any data necessary for sign-in
  Future<void> signIn();
}
