import "package:flutter/foundation.dart";

/// A data model to provide data to the app. 
/// 
/// A data model combines services with dataclasses to provide functionality. 
/// Whereas dataclasses don't care where they get their data from, and services
/// don't care what data they get, a data model uses dataclasses to structure
/// the data retrieved by a service. 
// ignore: prefer_mixin
abstract class Model with ChangeNotifier {
	/// Gets whatever data is needed by this model from a service. 
	/// 
	/// This model may not function properly if this function is not called. 
	Future<void> init();
}