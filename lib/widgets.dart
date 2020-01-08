/// A collection of widgets to use. 
/// 
/// There are three types of widgets in this library: 
/// 1. Generic widgets: miscellaneous widgets for use all around tha app.
/// 
/// 2. Atomic widgets: widgets that represent a single piece of data, (something
/// from the `data` library) with a canonic form all around the app. 
/// 
/// 3. Ambient widgets: Inherited widgets that can be accessed anywhere 
/// in the app using `BuildContext`s. 
library widgets;

// Ambient widgets can be accessed using `BuildContext`s
export "src/widgets/ambient/brightness_changer.dart";
export "src/widgets/ambient/services.dart";
export "src/widgets/ambient/theme_changer.dart";

// Atomic widgets represent a single data object.
export "src/widgets/atomic/activity_tile.dart";
export "src/widgets/atomic/next_class.dart";
export "src/widgets/atomic/reminder_tile.dart";

// Generic widgets are used in all sorts of situations.
export "src/widgets/generic/class_list.dart";
export "src/widgets/generic/date_picker.dart";
export "src/widgets/generic/footer.dart";
export "src/widgets/generic/icons.dart";
export "src/widgets/generic/model_listener.dart";
export "src/widgets/generic/reminder_builder.dart";
