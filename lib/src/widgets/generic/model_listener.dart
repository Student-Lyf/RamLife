import "package:flutter/material.dart";

/// A widget that rebuilds when the underlying data changes. 
abstract class ModelListener<
  M extends ChangeNotifier, 
  T extends StatefulWidget
> extends State<T> {
  /// The data model to listen to.
  late final M model;

  /// Whether we should dispose the model after use.
  /// 
  /// Some models are used multiple times, so they should not be disposed.
  final bool shouldDispose;

  /// Creates a widget that updates when the underlying data changes
  ModelListener({this.shouldDispose = true});

  /// The function to create the data model
  /// 
  /// This has to be overriden in a `State`
  M getModel();
  
  void _listener() => setState(() {});
  
  @override
  void initState() {
    super.initState();
    model = getModel();
    model.addListener(_listener);
  }
  
  @override
  void dispose() {
    model.removeListener(_listener);
    if (shouldDispose) {
      model.dispose();
    }
    super.dispose();
  }
}
