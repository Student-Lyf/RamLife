import "package:flutter/foundation.dart";

import "package:ramaz/models.dart";
import "package:ramaz/services_collection.dart";

/// A ViewModel for the home page. 
/// 
/// The home page does not actually need it's own ViewModel -- it pulls data
/// from other DataModels. But (currently), there is no efficient way for a 
/// widget to listen to more than one DataModel, this ViewModel was made to  
/// consolidate them into a single listener. 
// ignore: prefer_mixin
class HomeModel with ChangeNotifier {
	/// The schedule data model. 
	final Schedule schedule; 

	/// The sports data model.
	final Sports sports;

	/// Creates a ViewModel for the homescreen. 
	HomeModel(ServicesCollection services) : 
		schedule = services.schedule,
		sports = Sports(services.reader)
	{
		schedule.addListener(notifyListeners);
		sports.addListener(notifyListeners);
	}

	@override
	void dispose() {
		schedule.removeListener(notifyListeners);
		sports.removeListener(notifyListeners);
		super.dispose();
	}
}
