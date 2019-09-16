/// An abstraction over device services and data sources. 
/// 
/// The services library serves two purposes: 
/// 
/// 1. To abstract device functions. 
/// 
/// 	For example, device notifications can be abstracted away from the 
/// 	business logic to provide for a platform-agnostic implementation. 
/// 
/// 2. To abstract data sources: 
/// 	
/// 	For example, retrieving data from a database or file can be abstracted
/// 	to keep the app focused on the content of the data rather than how to 
/// 	properly access it. 
/// 
library ramaz_services;

export "src/services/auth.dart";
export "src/services/fcm.dart";
export "src/services/firestore.dart";
export "src/services/notifications.dart";
export "src/services/preferences.dart";
export "src/services/reader.dart";
