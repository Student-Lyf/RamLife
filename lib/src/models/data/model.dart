import "package:flutter/foundation.dart";

/// A data model to provide data to the app. 
/// 
/// A data model combines services with dataclasses to provide functionality. 
/// Whereas dataclasses don't care where they get their data from, and services
/// don't care what data they get, a data model uses dataclasses to structure
/// the data retrieved by a service. 
/// 
/// A data model should have functions and properties that the app as a whole 
/// may need. Any part of the UI may depend on any part of a data model. To 
/// update that data, call [notifyListeners], and every UI element that depends
/// on it will update. 
/// 
/// When implementing a data model, use the constructor for any synchronous 
/// work, such as accessing another data model. For any async work, override the
/// [init] function. For cleanup, override the [dispose] function. 
// ignore: prefer_mixin
abstract class Model with ChangeNotifier {
	/// Gets whatever data is needed by this model from a service. 
	/// 
	/// This model may not function properly if this function is not called. 
	Future<void> init();
}