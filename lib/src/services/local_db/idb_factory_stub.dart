import "package:idb_shim/idb_shim.dart";

/// Provides access to an IndexedDB implementation. 
/// 
/// Throws an error on an unrecognized platform. 
Future<IdbFactory> get idbFactory => throw UnsupportedError("Unknown platform");
